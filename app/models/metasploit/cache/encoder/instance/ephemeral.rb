# Ephemeral cache for connecting an in-memory encoder Metasploit Module's ruby instance to its persisted {Metasploit::Cache::}
class Metasploit::Cache::Encoder::Instance::Ephemeral < Metasploit::Model::Base
  extend Metasploit::Cache::ResurrectingAttribute

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
  resurrecting_attr_accessor(:encoder_instance) {
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

  # @note This ephemeral cache should be validated with `#valid?` prior to calling {#persist} to ensure that {#logger}
  #   is present in case of error.
  # @note Validation errors for `encoder_instance` will be logged as errors tagged with
  #   {Metasploit::Cache::Module::Ancestor#real_pathname}.
  #
  # @param to [Metasploit::Cache::Encoder::Instance] Sve cacheable data to {Metasploit::Cache::Encoder::Instance}.
  #   Giving `to` saves a database lookup if {#encoder_instance} is not loaded.
  # @return [Metasploit::Cache:Encoder::Instance] `#persisted?` will be `false` if saving fails.
  def persist(to: encoder_instance)
    persisted = nil

    ActiveRecord::Base.connection_pool.with_connection do
      synchronizers = [
          Metasploit::Cache::Ephemeral.synchronizer(:description, :name),
          Metasploit::Cache::Architecturable::Ephemeral::ArchitecturableArchitectures,
          Metasploit::Cache::Contributable::Ephemeral::Contributions,
          Metasploit::Cache::Licensable::Ephemeral::LicensableLicenses,
          Metasploit::Cache::Platformable::Ephemeral::PlatformablePlatforms
      ]

      with_encoder_instance_tag(to) do |tagged|
        synchronized = synchronizers.reduce(to) { |block_destination, synchronizer|
          synchronizer.synchronize(
              destination: block_destination,
              logger: logger,
              source: metasploit_module_instance
          )
        }

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
  
  # Tags log with {Metasploit::Cache::Encoder::Instance#encoder_class}
  # {Metasploit::Cache::Encoder::Class#ancestor} {Metasploit::Cache::Module::Ancestor#real_pathname}.
  #
  # @param encoder_instance [Metasploit::Cache::Encoder::Instance]
  # @yield [tagged_logger]
  # @yieldparam tagged_logger [ActiveSupport::TaggedLogger] {#logger} with
  #   {Metasploit::Cache::Module#Ancestor#real_pathname} tag.
  # @yieldreturn [void]
  # @return [void]
  def with_encoder_instance_tag(encoder_instance, &block)
    real_path = encoder_instance.encoder_class.ancestor.real_pathname.to_s

    Metasploit::Cache::Logged.with_tagged_logger(ActiveRecord::Base, logger, real_path, &block)
  end
end