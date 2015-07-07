# Ephemeral cache for connecting an in-memory auxiliary Metasploit Module's ruby instance to its persisted
# {Metasploit::Cache::Auxiliary::Instance}.
class Metasploit::Cache::Auxiliary::Instance::Ephemeral < Metasploit::Model::Base
  extend ActiveSupport::Autoload
  extend Metasploit::Cache::ResurrectingAttribute

  autoload :Actions

  #
  # Attributes
  #

  # The in-memory auxiliary Metasploit Module instance being cached.
  #
  # @return [Object]
  attr_accessor :auxiliary_metasploit_module_instance

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

  validates :auxiliary_metasploit_module_instance,
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
    to.stance = auxiliary_metasploit_module_instance.stance

    action_synchronized = Metasploit::Cache::Auxiliary::Instance::Ephemeral::Actions.synchronize(
        destination: to,
        source: auxiliary_metasploit_module_instance
    )
    to = Metasploit::Cache::Contributable::Ephemeral::Contributions.synchronize(
        destination: action_synchronized,
        source: auxiliary_metasploit_module_instance
    )

    saved = ActiveRecord::Base.connection_pool.with_connection {
      to.batched_save
    }

    unless saved
      log_error(to) {
        "Could not be persisted to #{to.class}: #{to.errors.full_messages.to_sentence}"
      }
    end

    to
  end

  private

  # Logs errors to {#logger} with `auxiliary_instance`'s {Metasploit::Cache::Auxiliary::Instance#auxiliary_class}'s
  # {Metasploit::Cache::Direct::Class#ancestor}'s {Metasploit::Cache::Module::Ancestor#real_pathname}.
  #
  # @yield Block called when logger severity is error or worse.
  # @yieldreturn [String] Message to print to log as error if logger severity level allows for print of ERROR messages.
  # @return [void]
  def log_error(auxiliary_instance, &block)
    if logger.error?
      real_path = ActiveRecord::Base.connection_pool.with_connection {
        auxiliary_instance.auxiliary_class.ancestor.real_pathname.to_s
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
    auxiliary_metasploit_module_instance.class.ephemeral_cache_by_source[:ancestor].real_path_sha1_hex_digest
  end
end