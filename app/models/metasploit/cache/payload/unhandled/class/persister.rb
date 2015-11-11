# Connects an in-memory payload unhandled Metasploit Module's ruby Class to its persisted
# {Metasploit::Cache::Payload::Unhandled::Class}.
class Metasploit::Cache::Payload::Unhandled::Class::Persister < Metasploit::Cache::Module::Persister
  include Metasploit::Cache::Module::Class::Persister::PersistentClass

  #
  # CONSTANTS
  #

  # Synchronizes attributes and associations from {#ephemeral} before persisting to database.
  SYNCHRONIZERS = [
      Metasploit::Cache::Module::Class::Persister::Rank
  ]

  #
  # Instance Methods
  #

  private

  # {Metasploit::Cache::Module::Ancestor#real_path_sha1_hex_digest} used to resurrect {#direct_class}.
  #
  # @return [String]
  def real_path_sha1_hex_digest
    ephemeral.persister_by_source[:ancestor].real_path_sha1_hex_digest
  end

  # Tags log with {Metasploit::Cache::Payload::Unhandled::Class#ancestor}
  # {Metasploit::Cache::Module::Ancestor#real_pathname}.
  #
  # @param payload_unhandled_class [Metasploit::Cache::Payload::Unhandled::Class, #ancestor]
  # @yield [tagged_logger]
  # @yieldparam tagged_logger [ActiveSupport::TaggedLogger] {#logger} with
  #   {Metasploit::Cache::Module#Ancestor#real_pathname} tag.
  # @yieldreturn [void]
  # @return [void]
  def with_tagged_logger(payload_unhandled_class, &block)
    Metasploit::Cache::Module::Ancestor::Persister.with_tagged_logger(logger, payload_unhandled_class.ancestor, &block)
  end
end
