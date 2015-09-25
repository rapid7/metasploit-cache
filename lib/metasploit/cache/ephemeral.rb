# Operations common to ephemeral caches
module Metasploit::Cache::Ephemeral
  extend ActiveSupport::Autoload

  autoload :AttributeSet

  #
  # CONSTANTS
  #

  # The maximum numbers of times to retry in {create_unique}
  MAX_RETRIES = 5

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
      Metasploit::Cache::Batch.batch do
        record_class.transaction(requires_new: true) do
          record_class.find_or_create_by!(attributes)
        end
      end
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

        retry
      else
        raise record_not_unique
      end
    rescue ActiveRecord::RecordInvalid => record_invalid
      record_invalid.record
    end
  end
end