# Ephemeral cache for connecting an in-memory payload_stage Metasploit Module's ruby instance to its persisted {Metasploit::Cache::}
class Metasploit::Cache::Payload::Stage::Instance::Ephemeral < Metasploit::Model::Base
  extend Metasploit::Cache::ResurrectingAttribute

  #
  # CONSTANTS
  #

  # Modules used to synchronize attributes and associations before persisting to database.
  SYNCHRONIZERS = [
      Metasploit::Cache::Ephemeral.synchronizer(:description, :name, :privileged),
      Metasploit::Cache::Architecturable::Ephemeral::ArchitecturableArchitectures,
      Metasploit::Cache::Contributable::Ephemeral::Contributions,
      Metasploit::Cache::Licensable::Ephemeral::LicensableLicenses,
      Metasploit::Cache::Platformable::Ephemeral::PlatformablePlatforms
  ]

  #
  # Attributes
  #

  # The in-memory payload_stage Metasploit Module instance being cached.
  #
  # @return [Object]
  attr_accessor :metasploit_module_instance

  # Tagged logger to which to log {#persist} errors.
  #
  # @return [ActiveSupport::TaggerLogger]
  attr_accessor :logger

  #
  # Resurrecting Attributes
  #

  # Cached metadata for this {#metasploit_module_instance}.
  #
  # @return [Metasploit::Cache::Payload::Stage::Instance]
  resurrecting_attr_accessor(:persistent) {
    ActiveRecord::Base.connection_pool.with_connection {
      Metasploit::Cache::Payload::Stage::Instance.joins(
          payload_stage_class: :ancestor
      ).where(
           Metasploit::Cache::Module::Ancestor.arel_table[:real_path_sha1_hex_digest].eq(real_path_sha1_hex_digest)
      ).readonly(false).first
    }
  }

  #
  # Validations
  #

  validates :metasploit_module_instance,
            presence: true
  validates :logger,
            presence: true

  #
  # Instance Methods
  #

  # @note This ephemeral cache should be validated with `#valid?` prior to calling {#persist} to ensure that {#logger}
  #   is present in case of error.
  # @note Validation errors for `payload_stage_instance` will be logged as errors tagged with
  #   {Metasploit::Cache::Module::Ancestor#real_pathname}.
  #
  # @param to [Metasploit::Cache::Payload::Stage::Instance] Sve cacheable data to {Metasploit::Cache::Payload::Stage::Instance}.
  #   Giving `to` saves a database lookup if {#payload_stage_instance} is not loaded.
  # @return [Metasploit::Cache:Payload::Stage::Instance] `#persisted?` will be `false` if saving fails.
  def persist(to: persistent)
    persisted = nil

    ActiveRecord::Base.connection_pool.with_connection do
      with_tagged_logger(to) do |tagged|
        synchronized = Metasploit::Cache::Ephemeral.synchronize destination: to,
                                                                logger: tagged,
                                                                source: metasploit_module_instance,
                                                                synchronizers: SYNCHRONIZERS

        persisted = Metasploit::Cache::Ephemeral.persist logger: tagged,
                                                         record: synchronized
      end
    end

    persisted
  end

  private

  # {Metasploit::Cache::Module::Ancestor#real_path_sha1_hex_digest} used to resurrect {#auxiliary_instance}.
  #
  # @return [String]
  def real_path_sha1_hex_digest
    metasploit_module_instance.class.ephemeral_cache_by_source[:ancestor].real_path_sha1_hex_digest
  end
  
  # Tags log with {Metasploit::Cache::Payload::Stage::Instance#payload_stage_class}
  # {Metasploit::Cache::Payload::Stage::Class#ancestor} {Metasploit::Cache::Module::Ancestor#real_pathname}.
  #
  # @param payload_stage_instance [Metasploit::Cache::Payload::Stage::Instance]
  # @yield [tagged_logger]
  # @yieldparam tagged_logger [ActiveSupport::TaggedLogger] {#logger} with
  #   {Metasploit::Cache::Module#Ancestor#real_pathname} tag.
  # @yieldreturn [void]
  # @return [void]
  def with_tagged_logger(payload_stage_instance, &block)
    Metasploit::Cache::Module::Ancestor::Ephemeral.with_tagged_logger(
        logger,
        payload_stage_instance.payload_stage_class.ancestor,
        &block
    )
  end
end