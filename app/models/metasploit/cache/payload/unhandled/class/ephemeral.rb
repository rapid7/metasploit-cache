# Ephemeral Cache for connecting an in-memory payload unhandled Metasploit Module's ruby Class to its persisted
# {Metasploit::Cache::Payload::Unhandled::Class}.
class Metasploit::Cache::Payload::Unhandled::Class::Ephemeral < Metasploit::Model::Base
  extend Metasploit::Cache::ResurrectingAttribute

  #
  # Attributes
  #

  # The subclass of {Metasploit::Cache::Payload::Unhandled::Class} to use to look up {#payload_unhandled_class}.
  #
  # @return [Class<Metasploit::Cache::Payload::Unhandled::Class>]
  attr_accessor :payload_unhandled_class_class

  # Tagged logger to which to log {#persist} errors.
  #
  # @return [ActiveSupport::TaggedLogging]
  attr_accessor :logger

  # The Metasploit Module being cached.
  #
  # @return [Class]
  attr_accessor :metasploit_class

  #
  # Resurrecting Attributes
  #

  # Cached metadata for this Class.
  #
  # @return [Metasploit::Cache::Payload::Unhandled::Class]
  resurrecting_attr_accessor :payload_unhandled_class do
    ActiveRecord::Base.connection_pool.with_connection {
      payload_unhandled_class_class.where(
          Metasploit::Cache::Module::Ancestor.arel_table[:real_path_sha1_hex_digest].eq(real_path_sha1_hex_digest)
      ).joins(:ancestor).readonly(false).first
    }
  end

  #
  # Validations
  #

  validates :logger,
            presence: true
  validates :metasploit_class,
            presence: true
  validates :payload_unhandled_class_class,
            presence: true

  #
  # Instance Methods
  #

  # @note This ephemeral cache should be validated with `valid?` prior to calling {#persist} to ensure that {#logger} is
  #   present in case of error.
  # @note Validation errors for `to` will be logged as errors tagged with
  #   {Metasploit::Cache::Module::Ancestor#real_pathname}.
  #
  # @param to [Metasploit::Cache::Payload::Unhandled::Class] Save cacheable data to
  #   {Metasploit::Cache::Payload::Unhandled::Class}.
  # @return [Metasploit::Cache::Payload::Unhandled::Class] `#persisted?` will be `false` if saving fails.
  def persist(to: payload_unhandled_class)
    with_payload_unhandled_class_tag(to) do |tagged|
      # set directly on `to` so that caller can see `nil` value.
      to.rank =  metasploit_class_module_rank(logger: tagged)

      # Ensure that connection is only held temporarily by Thread instead of being memoized to Thread
      saved = ActiveRecord::Base.connection_pool.with_connection {
        to.batched_save
      }

      unless saved
        tagged.error {
          "Could not be persisted to #{to.class}: #{to.errors.full_messages.to_sentence}"
        }
      end
    end

    to
  end

  private

  # Persisted form of {#metasploit_class}'s `rank`.
  #
  # @param logger [ActiveSupport::TaggedLogger] logger already tagged with
  #   {Metasploit::Cache::Module::Ancestor#real_pathname}.
  # @return [Metasploit::Cache::Module::Rank] persisted rank corresponding to {#metasploit_class}'s rank.'
  # @return [nil] if {#metasploit_class} does not respond to `rank`
  # @return [nil] if {#metasploit_class}'s `rank` is not a seeded {Metasploit::Cache::Module::Rank#number}.
  def metasploit_class_module_rank(logger:)
    module_rank = nil

    if metasploit_class.respond_to? :rank
      rank_number = metasploit_class.rank

      # Ensure that connection is only held temporarily by Thread instead of being memoized to Thread
      module_rank = ActiveRecord::Base.connection_pool.with_connection {
        Metasploit::Cache::Module::Rank.where(number: rank_number).first
      }

      if module_rank.nil?
        name = Metasploit::Cache::Module::Rank::NAME_BY_NUMBER[rank_number]

        if name.nil?
          logger.error {
            "Metasploit::Cache::Module::Rank with #number (#{rank_number}) is not in list of allowed #numbers " \
            "(#{Metasploit::Cache::Module::Rank::NAME_BY_NUMBER.keys.sort.to_sentence})"
          }
        else
          logger.error {
            "Metasploit::Cache::Module::Rank with #number (#{rank_number}) is not seeded"
          }
        end
      end
    else
      logger.error {
        "#{metasploit_class} does not respond to rank. " \
        "It should return the `Metasploit::Cache::Module::Rank#number`."
      }
    end

    module_rank
  end

  # {Metasploit::Cache::Module::Ancestor#real_path_sha1_hex_digest} used to resurrect {#direct_class}.
  #
  # @return [String]
  def real_path_sha1_hex_digest
    metasploit_class.ephemeral_cache_by_source[:ancestor].real_path_sha1_hex_digest
  end

  # Tags log with {Metasploit::Cache::Payload::Unhandled::Class#ancestor}
  # {Metasploit::Cache::Module::Ancestor#real_pathname}.
  #
  # @param payload_unhandled_class [Metasploit::Cache::Payload::Unhandled::Class, #ancestor]
  # @yield [tagged_logger]
  # @yieldparam tagged_logger [ActiveSupport::TaggedLogger] {#logger} with
  #   {Metasploit::Cache::Module#Ancestor#real_pathname} tag.
  # @yieldreturn [void]
  # @return [void]
  def with_payload_unhandled_class_tag(payload_unhandled_class, &block)
    real_path = ActiveRecord::Base.connection_pool.with_connection {
      payload_unhandled_class.ancestor.real_pathname.to_s
    }

    Metasploit::Cache::Logged.with_tagged_logger(ActiveRecord::Base, logger, real_path, &block)
  end
end
