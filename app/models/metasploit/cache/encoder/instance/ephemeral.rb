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
    [:description, :name].each do |attribute|
      to.send("#{attribute}=", metasploit_module_instance.send(attribute))
    end

    synchronizers = [
        Metasploit::Cache::Architecturable::Ephemeral::ArchitecturableArchitectures,
        Metasploit::Cache::Contributable::Ephemeral::Contributions,
        Metasploit::Cache::Licensable::Ephemeral::LicensableLicenses,
        Metasploit::Cache::Platformable::Ephemeral::PlatformablePlatforms
    ]

    synchronized = synchronizers.reduce(to) { |block_destination, synchronizer|
      synchronizer.synchronize(
          destination: block_destination,
          source: metasploit_module_instance
      )
    }

    saved = ActiveRecord::Base.connection_pool.with_connection {
      synchronized.batched_save
    }

    unless saved
      log_error(synchronized) {
        "Could not be persisted to #{synchronized.class}: #{synchronized.errors.full_messages.to_sentence}"
      }
    end

    synchronized
  end

  private

  # Logs errors to {#logger} with `encoder_instance`'s {Metasploit::Cache::Encoder::Instance#encoder_class}'s
  # {Metasploit::Cache::Direct::Class#ancestor}'s {Metasploit::Cache::Module::Ancestor#real_pathname}.
  #
  # @yield Block called when logger severity is error or worse.
  # @yieldreturn [String] Message to print to log as error if logger severity level allows for print of ERROR messages.
  # @return [void]
  def log_error(encoder_instance, &block)
    if logger.error?
      real_path = ActiveRecord::Base.connection_pool.with_connection {
        encoder_instance.encoder_class.ancestor.real_pathname.to_s
      }

      logger.tagged(real_path) do |tagged|
        tagged.error(&block)
      end
    end
  end

  # {Metasploit::Cache::Module::Ancestor#real_path_sha1_hex_digest} used to resurrect {#auxiliary_instance}.
  #
  # @return [String]
  def real_path_sha1_hex_digest
    metasploit_module_instance.class.ephemeral_cache_by_source[:ancestor].real_path_sha1_hex_digest
  end
end