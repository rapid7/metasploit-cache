# Ephemeral cache for connecting an in-memory auxiliary Metasploit Module's ruby instance to its persisted
# {Metasploit::Cache::Auxiliary::Instance}.
class Metasploit::Cache::Auxiliary::Instance::Ephemeral < Metasploit::Model::Base
  extend ActiveSupport::Autoload
  extend Metasploit::Cache::ResurrectingAttribute

  #
  # Attributes
  #

  # The in-memory auxiliary Metasploit Module instance being cached.
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

  # Cached metadata for this {#metasploit_instance}
  #
  # @return [Metasploit::Cache::Auxiliary::Instance]
  resurrecting_attr_accessor :auxiliary_instance do
    ActiveRecord::Base.connection_pool.with_connection {
      Metasploit::Cache::Auxiliary::Instance.joins(
          auxiliary_class: :ancestor
      ).where(
          Metasploit::Cache::Module::Ancestor.arel_table[:real_path_sha1_hex_digest].eq(real_path_sha1_hex_digest)
      ).readonly(false).first
    }
  end

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

  # @note This ephemeral cache should be validated with `valid?` prior to calling {#persist} to ensure that {#logger} is
  #   present in case of error.
  # @note Validation errors for `auxiliary_instance` will be logged as errors tagged with
  #   {Metasploit::Cache::Module::Ancestor#real_pathname}.
  #
  # @param to [Metasploit::Cache::Auxiliary::Instance] Save cacheable data to {Metasploit::Cache::Auxiliary::Instance}.
  #   Giving `to` saves a database lookup if {#auxiliary_instance} is not loaded.
  # @return [Metasploit::Cache::Auxiliary::Instance] `#persisted?` will be `false` if saving fails.
  def persist(to: auxiliary_instance)
    [:description, :name].each do |attribute|
      to.send("#{attribute}=", metasploit_module_instance.send(attribute))
    end

    if metasploit_module_instance.passive?
      to.stance = Metasploit::Cache::Module::Stance::PASSIVE
    else
      to.stance = Metasploit::Cache::Module::Stance::AGGRESSIVE
    end

    synchronizers = [
        Metasploit::Cache::Actionable::Ephemeral::Actions,
        Metasploit::Cache::Contributable::Ephemeral::Contributions,
        Metasploit::Cache::Licensable::Ephemeral::LicensableLicenses
    ]

    synchronized = nil

    with_auxiliary_instance_tag(to) do |tagged|
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

  # Tags log with {Metasploit::Cache::Auxiliary::Instance#auxiliary_class}
  # {Metasploit::Cache::Auxiliary::Class#ancestor} {Metasploit::Cache::Module::Ancestor#real_pathname}.
  #
  # @param auxiliary_instance [Metasploit::Cache::Auxiliary::Instance]
  # @yield [tagged_logger]
  # @yieldparam tagged_logger [ActiveSupport::TaggedLogger] {#logger} with
  #   {Metasploit::Cache::Module#Ancestor#real_pathname} tag.
  # @yieldreturn [void]
  # @return [void]
  def with_auxiliary_instance_tag(auxiliary_instance, &block)
    real_path = ActiveRecord::Base.connection_pool.with_connection {
      auxiliary_instance.auxiliary_class.ancestor.real_pathname.to_s
    }

    Metasploit::Cache::Logged.with_tagged_logger(ActiveRecord::Base, logger, real_path, &block)
  end
end