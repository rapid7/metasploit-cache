# Connects an in-memory single payload Metasploit Module's ruby Class to its persisted
# {Metasploit::Cache::Payload::Single::Handled::Class}.
class Metasploit::Cache::Payload::Single::Handled::Class::Persister < Metasploit::Model::Base
  extend ActiveSupport::Autoload
  extend Metasploit::Cache::ResurrectingAttribute

  autoload :Name

  #
  # CONSTANTS
  #

  # Modules used to synchronize attributes and associations before persisting to database.
  SYNCHRONIZERS = [
      self::Name
  ]

  #
  # Attributes
  #

  # Tagged logger to which to log {#persist} errors.
  #
  # @return [ActiveSupport::TaggedLogging]
  attr_accessor :logger

  # The Metasploit Module being cached.
  #
  # @return [Class]
  attr_accessor :payload_single_handled_metasploit_module_class

  #
  # Resurrecting Attributes
  #

  # Cached metadata for this Class.
  #
  # @return [Metasploit::Cache::Direct::Class]
  resurrecting_attr_accessor(:persistent) {
    ActiveRecord::Base.connection_pool.with_connection {
      Metasploit::Cache::Payload::Single::Handled::Class.joins(
          payload_single_unhandled_instance: {
              payload_single_unhandled_class: :ancestor
          }
      ).where(
           Metasploit::Cache::Module::Ancestor.arel_table[:real_path_sha1_hex_digest].eq(real_path_sha1_hex_digest)
      ).readonly(false).first
    }
  }

  #
  # Validations
  #

  validates :logger,
            presence: true
  validates :payload_single_handled_metasploit_module_class,
            presence: true

  #
  # Class Methods
  #

  # Tags log with {Metasploit::Cache::Payload::Single::Handled::Class#payload_single_unhandled_instance}
  # {Metasploit::Cache::Payload::Single::Unhandled::Instance#payload_single_unhandled_class}
  # {Metasploit::Cache::Payload::Single::Unhandled::Class#ancestor} {Metasploit::Cache::Module::Ancestor#real_pathname}.
  #
  # @param logger [ActiveSupport::TaggedLoggin]
  # @param payload_single_handled_class [Metasploit::Cache::Payload::Single::Unhandled::Class]
  # @yield [tagged_logger]
  # @yieldparam tagged_logger [ActiveSupport::TaggedLogger] {#logger} with
  #   {Metasploit::Cache::Module#Ancestor#real_pathname} tags.
  # @yieldreturn [void]
  # @return [void]
  def self.with_tagged_logger(logger, payload_single_handled_class, &block)
    Metasploit::Cache::Module::Ancestor::Persister.with_tagged_logger(
        logger,
        payload_single_handled_class.payload_single_unhandled_instance.payload_single_unhandled_class.ancestor,
        &block
    )
  end

  #
  # Instance Methods
  #

  # @note This persister should be validated with `valid?` prior to calling {#persist} to ensure that {#logger} is
  #   present in case of error.
  # @note Validation errors for `payload_single_handled_class` will be logged as errors tagged with
  #   {Metasploit::Cache::Payload::Single::Handled::Class#payload_single_unhandled_instance}
  #   {Metasploit::Cache::Payload::Single::Unhandled::Instance#payload_single_unhandled_class}
  #   {Metasploit::Cache::Payload::Single::Unhandled::Class#ancestor}
  #   {Metasploit::Cache::Module::Ancestor#real_pathname}.
  #
  # @param to [Metasploit::Cache::Payload::Single::Handled::Class] Save cacheable data to
  #   {Metasploit::Cache::Payload::Single::Handled::Class}.
  # @return [Metasploit::Cache::Payload::Single::Handled::Class] `#persisted?` will be `false` if saving fails.
  def persist(to: persistent)
    persisted = nil

    ActiveRecord::Base.connection_pool.with_connection do
      with_tagged_logger(to) do |tagged|
        persisted = Metasploit::Cache::Persister.persist destination: to,
                                                         logger: tagged,
                                                         source: payload_single_handled_metasploit_module_class,
                                                         synchronizers: SYNCHRONIZERS
      end
    end

    persisted
  end

  private

  # {Metasploit::Cache::Module::Ancestor#real_path_sha1_hex_digest} used to resurrect {#payload_single_handled_class}.
  #
  # @return [String]
  def real_path_sha1_hex_digest
    payload_single_handled_metasploit_module_class.persister_by_source.fetch(:ancestor).real_path_sha1_hex_digest
  end

  # Tags log with {Metasploit::Cache::Payload::Single::Handled::Class#payload_single_unhandled_instance}
  # {Metasploit::Cache::Payload::Single::Unhandled::Instance#payload_single_unhandled_class}
  # {Metasploit::Cache::Payload::Single::Unhandled::Class#ancestor} {Metasploit::Cache::Module::Ancestor#real_pathname}.
  #
  # @param payload_single_handled_class [Metasploit::Cache::Payload::Single::Unhandled::Class]
  # @yield [tagged_logger]
  # @yieldparam tagged_logger [ActiveSupport::TaggedLogger] {#logger} with
  #   {Metasploit::Cache::Module#Ancestor#real_pathname} tags.
  # @yieldreturn [void]
  # @return [void]
  def with_tagged_logger(payload_single_handled_class, &block)
    self.class.with_tagged_logger(logger, payload_single_handled_class, &block)
  end
end
