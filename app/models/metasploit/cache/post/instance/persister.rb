# Connects an in-memory post Metasploit Module's ruby instance to its persisted {Metasploit::Cache::}
class Metasploit::Cache::Post::Instance::Persister < Metasploit::Cache::Module::Persister
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
  # Instance Methods
  #

  protected

  # @return [ActiveRecord::Relation<Metasploit::Cache::Post::Instance>]
  def persistent_relation
    Metasploit::Cache::Post::Instance.joins(
        post_class: :ancestor
    ).where(
        Metasploit::Cache::Module::Ancestor.arel_table[:real_path_sha1_hex_digest].eq(real_path_sha1_hex_digest)
    )
  end

  private

  # {Metasploit::Cache::Module::Ancestor#real_path_sha1_hex_digest} used to resurrect {#auxiliary_instance}.
  #
  # @return [String]
  def real_path_sha1_hex_digest
    ephemeral.class.persister_by_source[:ancestor].real_path_sha1_hex_digest
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