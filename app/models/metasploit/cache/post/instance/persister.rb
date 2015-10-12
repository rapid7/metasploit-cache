# Connects an in-memory post Metasploit Module's ruby instance to its persisted {Metasploit::Cache::}
class Metasploit::Cache::Post::Instance::Persister < Metasploit::Model::Base
  extend Metasploit::Cache::ResurrectingAttribute

  #
  # CONSTANTS
  #

  # Modules used to synchronize attributes and associations before persisting to database.
  SYNCHRONIZERS = [
      Metasploit::Cache::Persister.synchronizer(
          :description,
          :name,
          :privileged,
          disclosure_date: :disclosed_on
      ),
      Metasploit::Cache::Actionable::Persister::Actions,
      Metasploit::Cache::Architecturable::Persister::ArchitecturableArchitectures,
      Metasploit::Cache::Contributable::Persister::Contributions,
      Metasploit::Cache::Licensable::Persister::LicensableLicenses,
      Metasploit::Cache::Platformable::Persister::PlatformablePlatforms,
      Metasploit::Cache::Referencable::Persister::ReferencableReferences
  ]

  #
  # Attributes
  #

  # The in-memory post Metasploit Module instance being cached.
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
  # @return [Metasploit::Cache::Post::Instance]
  resurrecting_attr_accessor(:persistent) {
    ActiveRecord::Base.connection_pool.with_connection {
      Metasploit::Cache::Post::Instance.joins(
          post_class: :ancestor
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

  # @note This persister should be validated with `#valid?` prior to calling {#persist} to ensure that {#logger} is
  #   present in case of error.
  # @note Validation errors for `post_instance` will be logged as errors tagged with
  #   {Metasploit::Cache::Module::Ancestor#real_pathname}.
  #
  # @param to [Metasploit::Cache::Post::Instance] Sve cacheable data to {Metasploit::Cache::Post::Instance}.
  #   Giving `to` saves a database lookup if {#post_instance} is not loaded.
  # @return [Metasploit::Cache:Post::Instance] `#persisted?` will be `false` if saving fails.
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
  
  # Tags log with {Metasploit::Cache::Post::Instance#post_class}
  # {Metasploit::Cache::Post::Class#ancestor} {Metasploit::Cache::Module::Ancestor#real_pathname}.
  #
  # @param post_instance [Metasploit::Cache::Post::Instance]
  # @yield [tagged_logger]
  # @yieldparam tagged_logger [ActiveSupport::TaggedLogger] {#logger} with
  #   {Metasploit::Cache::Module#Ancestor#real_pathname} tag.
  # @yieldreturn [void]
  # @return [void]
  def with_tagged_logger(post_instance, &block)
    Metasploit::Cache::Module::Ancestor::Persister.with_tagged_logger logger,
                                                                      post_instance.post_class.ancestor,
                                                                      &block
  end
end