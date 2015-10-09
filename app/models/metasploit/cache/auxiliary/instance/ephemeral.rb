# Ephemeral cache for connecting an in-memory auxiliary Metasploit Module's ruby instance to its persisted
# {Metasploit::Cache::Auxiliary::Instance}.
class Metasploit::Cache::Auxiliary::Instance::Ephemeral < Metasploit::Model::Base
  extend ActiveSupport::Autoload
  extend Metasploit::Cache::ResurrectingAttribute

  autoload :Stance

  #
  # CONSTANTS
  #

  # Modules used to synchronize attributes and associations before persisting to database.
  SYNCHRONIZERS = [
      Metasploit::Cache::Ephemeral.synchronizer(:description, :name),
      Metasploit::Cache::Actionable::Ephemeral::Actions,
      self::Stance,
      Metasploit::Cache::Contributable::Ephemeral::Contributions,
      Metasploit::Cache::Licensable::Ephemeral::LicensableLicenses
  ]

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
  resurrecting_attr_accessor(:persistent) {
    ActiveRecord::Base.connection_pool.with_connection {
      Metasploit::Cache::Auxiliary::Instance.joins(
          auxiliary_class: :ancestor
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

  # @note This ephemeral cache should be validated with `valid?` prior to calling {#persist} to ensure that {#logger} is
  #   present in case of error.
  # @note Validation errors for `auxiliary_instance` will be logged as errors tagged with
  #   {Metasploit::Cache::Module::Ancestor#real_pathname}.
  #
  # @param to [Metasploit::Cache::Auxiliary::Instance] Save cacheable data to {Metasploit::Cache::Auxiliary::Instance}.
  #   Giving `to` saves a database lookup if {#auxiliary_instance} is not loaded.
  # @return [Metasploit::Cache::Auxiliary::Instance] `#persisted?` will be `false` if saving fails.
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

  # Tags log with {Metasploit::Cache::Auxiliary::Instance#auxiliary_class}
  # {Metasploit::Cache::Auxiliary::Class#ancestor} {Metasploit::Cache::Module::Ancestor#real_pathname}.
  #
  # @param auxiliary_instance [Metasploit::Cache::Auxiliary::Instance]
  # @yield [tagged_logger]
  # @yieldparam tagged_logger [ActiveSupport::TaggedLogger] {#logger} with
  #   {Metasploit::Cache::Module#Ancestor#real_pathname} tag.
  # @yieldreturn [void]
  # @return [void]
  def with_tagged_logger(auxiliary_instance, &block)
    Metasploit::Cache::Module::Ancestor::Ephemeral.with_tagged_logger logger,
                                                                      auxiliary_instance.auxiliary_class.ancestor,
                                                                      &block
  end
end