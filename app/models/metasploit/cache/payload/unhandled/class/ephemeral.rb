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
  resurrecting_attr_accessor(:persistent) {
    ActiveRecord::Base.connection_pool.with_connection {
      payload_unhandled_class_class.where(
          Metasploit::Cache::Module::Ancestor.arel_table[:real_path_sha1_hex_digest].eq(real_path_sha1_hex_digest)
      ).joins(:ancestor).readonly(false).first
    }
  }

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
  def persist(to: persistent)
    persisted = nil

    ActiveRecord::Base.connection_pool.with_connection do
      with_tagged_logger(to) do |tagged|
        synchronized = Metasploit::Cache::Module::Class::Ephemeral::Rank.synchronize(
            destination: to,
            logger: tagged,
            source: metasploit_class
        )

        persisted = Metasploit::Cache::Ephemeral.persist logger: tagged,
                                                         record: synchronized
      end
    end

    persisted
  end

  private

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
  def with_tagged_logger(payload_unhandled_class, &block)
    Metasploit::Cache::Module::Ancestor::Ephemeral.with_tagged_logger(logger, payload_unhandled_class.ancestor, &block)
  end
end
