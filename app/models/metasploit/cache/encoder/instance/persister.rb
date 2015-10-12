# Connects an in-memory encoder Metasploit Module's ruby instance to its persisted
# {Metasploit::Cache::Encoder::Instance}.
class Metasploit::Cache::Encoder::Instance::Persister < Metasploit::Model::Base
  extend Metasploit::Cache::ResurrectingAttribute

  #
  # CONSTANTS
  #

  # Modules used to synchronize attributes and associations before persisting to database.
  SYNCHRONIZERS = [
      Metasploit::Cache::Persister.synchronizer(:description, :name),
      Metasploit::Cache::Architecturable::Persister::ArchitecturableArchitectures,
      Metasploit::Cache::Contributable::Persister::Contributions,
      Metasploit::Cache::Licensable::Persister::LicensableLicenses,
      Metasploit::Cache::Platformable::Persister::PlatformablePlatforms
  ]

  #
  # Attributes
  #

  # The in-memory encoder Metasploit Module instance being cached.
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
  # @return [Metasploit::Cache::Encoder::Instance]
  resurrecting_attr_accessor(:persistent) {
    ActiveRecord::Base.connection_pool.with_connection {
      Metasploit::Cache::Encoder::Instance.joins(
          encoder_class: :ancestor
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

  # @note This persister should be validated with `#valid?` prior to calling {#persist} to ensure that {#logger}
  #   is present in case of error.
  # @note Validation errors for `encoder_instance` will be logged as errors tagged with
  #   {Metasploit::Cache::Module::Ancestor#real_pathname}.
  #
  # @param to [Metasploit::Cache::Encoder::Instance] Sve cacheable data to {Metasploit::Cache::Encoder::Instance}.
  #   Giving `to` saves a database lookup if {#encoder_instance} is not loaded.
  # @return [Metasploit::Cache:Encoder::Instance] `#persisted?` will be `false` if saving fails.
  def persist(to: persistent)
    persisted = nil

    ActiveRecord::Base.connection_pool.with_connection do
      with_tagged_logger(to) do |tagged|
        persisted = Metasploit::Cache::Persister.persist destination: to,
                                                         logger: tagged,
                                                         source: metasploit_module_instance,
                                                         synchronizers: SYNCHRONIZERS
      end
    end

    persisted
  end

  private

  # {Metasploit::Cache::Module::Ancestor#real_path_sha1_hex_digest} used to resurrect {#auxiliary_instance}.
  #
  # @return [String]
  def real_path_sha1_hex_digest
    metasploit_module_instance.class.persister_by_source[:ancestor].real_path_sha1_hex_digest
  end
  
  # Tags log with {Metasploit::Cache::Encoder::Instance#encoder_class}
  # {Metasploit::Cache::Encoder::Class#ancestor} {Metasploit::Cache::Module::Ancestor#real_pathname}.
  #
  # @param encoder_instance [Metasploit::Cache::Encoder::Instance]
  # @yield [tagged_logger]
  # @yieldparam tagged_logger [ActiveSupport::TaggedLogger] {#logger} with
  #   {Metasploit::Cache::Module#Ancestor#real_pathname} tag.
  # @yieldreturn [void]
  # @return [void]
  def with_tagged_logger(encoder_instance, &block)
    Metasploit::Cache::Module::Ancestor::Persister.with_tagged_logger logger,
                                                                      encoder_instance.encoder_class.ancestor,
                                                                      &block
  end
end