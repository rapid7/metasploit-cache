# Operations common to ephemeral caches
module Metasploit::Cache::Ephemeral
  extend ActiveSupport::Autoload

  autoload :AttributeSet

  #
  # CONSTANTS
  #

  # The maximum numbers of times to retry in {create_unique}
  MAX_RETRIES = 5
  # Number of milliseconds in a second
  MILLISECONDS_PER_SECOND = 1000

  #
  # Module Methods
  #

  # Generates proc that can be used for `Hash#default_proc` that calls {create_unique} with the key for the
  # attribute with `attribute_name`.
  #
  # @param record_class (see create_unique)
  # @param attribute_name [Symbol] name of attribute for `Hash` key passed to `Hash#default_proc`.
  # @return [Proc<Hash, String>]
  def self.create_unique_proc(record_class, attribute_name)
    ->(hash, key) {
      hash[key] = create_unique(
          record_class,
          attribute_name => key
      )
    }
  end

  # Creates a new record and retries if there is a race that leads to `ActiveRecord::RecordNotUnique`.
  #
  # @param record_class [Class<ActiveRecord::Base, Metasploit::Cache::Batch::Descendant>] an `ActiveRecord::Base`
  #   subclass that includes `Metasploit::Cache::Batch::Descendant` so unique validations are raised as
  #   `ActiveRecord::RecordNotUnique` errors.
  # @param attributes [Hash] attributes for record
  # @return [ActiveRecord::Base] instance of `record_class`.
  def self.create_unique(record_class, attributes)
    count = 0

    begin
      Metasploit::Cache::Batch.batch {
        record_class.isolation_level(:serializable)  {
          record_class.transaction(requires_new: true) {
            record_class.find_or_create_by!(attributes)
          }
        }
      }
    rescue ActiveRecord::RecordNotUnique => record_not_unique
      count += 1

      if count <= MAX_RETRIES
        record_class.logger.debug {
          lines = ["#{count.ordinalize} retry caused by #{record_not_unique.message} (#{record_not_unique.class})"]

          if record_not_unique.backtrace
            lines.concat(record_not_unique.backtrace)
          end

          lines.join("\n")
        }

        milliseconds = rand(2 << count)
        seconds = milliseconds.fdiv(MILLISECONDS_PER_SECOND)
        sleep(seconds)

        retry
      else
        record_class.new(attributes)
      end
    rescue ActiveRecord::RecordInvalid => record_invalid
      record_invalid.record
    end
  end

  # @param common_and_source_to_destination [Array<Symbol, Hash{Symbol => Symbol}>] List of attribute names that are the
  #   same in destination and source, or a map of a source attribute to a destination attribute.
  # @return [#synchronize(destination:, logger:, source:)]
  def self.synchronizer(*common_and_source_to_destination)
    synchronizer = Module.new

    synchronizer.define_singleton_method(:synchronize) do |destination:, logger:, source:|
      common_and_source_to_destination.each do |common_or_source_to_destination|
        case common_or_source_to_destination
        when Hash
          source_to_destination = common_or_source_to_destination

          source_to_destination.each do |source_attribute, destination_attribute|
            destination.public_send("#{destination_attribute}=", source.public_send(source_attribute))
          end
        when Symbol
          common = common_or_source_to_destination
          destination.public_send("#{common}=", source.public_send(common))
        end
      end

      destination
    end

    synchronizer
  end

  # Attempts to persist `record` to database.
  #
  # @param logger [ActiveSupport::TaggedLogging] Tagged logger to which to log `record` validation errors if
  #   `#batched_save` fails.
  # @param record [ActiveRecord::Base, #batched_save, #errors] Record to attempt to batch save and log validation
  #   errors if not saved.
  # @return [ActiveRecord::Base] `#persisted?` will be `false` if saving fails.
  def self.persist(logger:, record:)
    record_class = record.class

    saved = record_class.isolation_level(:serializable) {
      record_class.transaction {
        record.batched_save
      }
    }

    unless saved
      logger.error {
        "Could not be persisted to #{record_class}: #{record.errors.full_messages.to_sentence}"
      }
    end

    record
  end
end