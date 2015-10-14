# Connects an in-memory payload_single Metasploit Module's ruby instance to its persisted
# {Metasploit::Cache::Payload::Single::Unhandled::Instance}.
class Metasploit::Cache::Payload::Single::Unhandled::Instance::Persister < Metasploit::Cache::Module::Persister
  #
  # CONSTANTS
  #

  # Modules used to synchronize attributes and associations before persisting to database.
  SYNCHRONIZERS = [
      Metasploit::Cache::Persister.synchronizer(:description, :name, :privileged),
      Metasploit::Cache::Architecturable::Persister::ArchitecturableArchitectures,
      Metasploit::Cache::Contributable::Persister::Contributions,
      Metasploit::Cache::Licensable::Persister::LicensableLicenses,
      Metasploit::Cache::Payload::Handable::Persister::Handler,
      Metasploit::Cache::Platformable::Persister::PlatformablePlatforms
  ]

  #
  # Instance Methods
  #

  protected

  # @return [ActiveRecord::Relation<Metasploit::Cache::Payload::Single::Unhandled::Instance>]
  def persistent_relation
    Metasploit::Cache::Payload::Single::Unhandled::Instance.joins(
        payload_single_unhandled_class: :ancestor
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
  
  # Tags log with {Metasploit::Cache::Payload::Single::Unhandled::Instance#payload_single_unhandled_class}
  # {Metasploit::Cache::Payload::Single::Unhandled::Class#ancestor} {Metasploit::Cache::Module::Ancestor#real_pathname}.
  #
  # @param payload_single_unhandled_instance [Metasploit::Cache::Payload::Single::Unhandled::Instance]
  # @yield [tagged_logger]
  # @yieldparam tagged_logger [ActiveSupport::TaggedLogger] {#logger} with
  #   {Metasploit::Cache::Module#Ancestor#real_pathname} tag.
  # @yieldreturn [void]
  # @return [void]
  def with_tagged_logger(payload_single_unhandled_instance, &block)
    Metasploit::Cache::Module::Ancestor::Persister.with_tagged_logger(
        logger,
        payload_single_unhandled_instance.payload_single_unhandled_class.ancestor,
        &block
    )
  end
end