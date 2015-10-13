# Connects an in-memory encoder Metasploit Module's ruby instance to its persisted
# {Metasploit::Cache::Encoder::Instance}.
class Metasploit::Cache::Encoder::Instance::Persister < Metasploit::Cache::Module::Persister
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
  # Instance Methods
  #

  protected

  # @return [ActiveRecord::Relation<Metasploit::Cache::Encoder::Instance>]
  def persistent_relation
    Metasploit::Cache::Encoder::Instance.joins(
        encoder_class: :ancestor
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