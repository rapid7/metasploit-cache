# Ephemeral cache for connecting an in-memory payload_single Metasploit Module's ruby instance to its persisted {Metasploit::Cache::}
class Metasploit::Cache::Payload::Single::Unhandled::Instance::Ephemeral < Metasploit::Model::Base
  extend Metasploit::Cache::ResurrectingAttribute

  #
  # Attributes
  #

  # The in-memory payload_single Metasploit Module instance being cached.
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
  # @return [Metasploit::Cache::Payload::Single::Unhandled::Instance]
  resurrecting_attr_accessor(:payload_single_unhandled_instance) {
    ActiveRecord::Base.connection_pool.with_connection {
      Metasploit::Cache::Payload::Single::Unhandled::Instance.joins(
          payload_single_unhandled_class: :ancestor
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
  # @note Validation errors for `payload_single_unhandled_instance` will be logged as errors tagged with
  #   {Metasploit::Cache::Module::Ancestor#real_pathname}.
  #
  # @param to [Metasploit::Cache::Payload::Single::Unhandled::Instance] Sve cacheable data to
  #   {Metasploit::Cache::Payload::Single::Unhandled::Instance}. Giving `to` saves a database lookup if
  #   {#payload_single_unhandled_instance} is not loaded.
  # @return [Metasploit::Cache:Payload::Single::Unhandled::Instance] `#persisted?` will be `false` if saving fails.
  def persist(to: payload_single_unhandled_instance)
    [:description, :name, :privileged].each do |attribute|
      to.send("#{attribute}=", metasploit_module_instance.send(attribute))
    end

    synchronizers = [
        Metasploit::Cache::Architecturable::Ephemeral::ArchitecturableArchitectures,
        Metasploit::Cache::Contributable::Ephemeral::Contributions,
        Metasploit::Cache::Licensable::Ephemeral::LicensableLicenses,
        Metasploit::Cache::Payload::Handable::Ephemeral::Handler,
        Metasploit::Cache::Platformable::Ephemeral::PlatformablePlatforms
    ]

    synchronized = nil

    with_payload_single_unhandled_instance_tag(to) do |tagged|
      synchronized = synchronizers.reduce(to) { |block_destination, synchronizer|
        synchronizer.synchronize(
            destination: block_destination,
            logger: logger,
            source: metasploit_module_instance
        )
      }

      saved = ActiveRecord::Base.connection_pool.with_connection {
        synchronized_class = synchronized.class

        synchronized_class.isolation_level(:serializable) {
          synchronized_class.transaction {
            synchronized.batched_save
          }
        }
      }

      unless saved
        tagged.error {
          "Could not be persisted to #{synchronized.class}: #{synchronized.errors.full_messages.to_sentence}"
        }
      end
    end

    synchronized
  end

  private

  # {Metasploit::Cache::Module::Ancestor#real_path_sha1_hex_digest} used to resurrect {#auxiliary_instance}.
  #
  # @return [String]
  def real_path_sha1_hex_digest
    metasploit_module_instance.class.ephemeral_cache_by_source[:ancestor].real_path_sha1_hex_digest
  end
  
  # Tags log with {Metasploit::Cache::Payload::Single::Unhandled::Instance#payload_single_unhandled_class}
  # {Metasploit::Cache::Payload::Single::Unhandled::Class#ancestor} {Metasploit::Cache::Module::Ancestor#real_pathname}.
  #
  # @param payload_single_unhandled_instance [Metasploit::Cache::Payload::Single::Unhandled::Instance]
  # @yield [tagged_logger]
  # @yieldparam tagged_logger [ActiveSupport::TaggedLogger] {#logger} with
  #   {Metasploit::Cache::Module#Ancestor#real_pathname} tag.
  # @yieldreturn [void]
  # @return [void]
  def with_payload_single_unhandled_instance_tag(payload_single_unhandled_instance, &block)
    real_path = ActiveRecord::Base.connection_pool.with_connection {
      payload_single_unhandled_instance.payload_single_unhandled_class.ancestor.real_pathname.to_s
    }

    Metasploit::Cache::Logged.with_tagged_logger(ActiveRecord::Base, logger, real_path, &block)
  end
end