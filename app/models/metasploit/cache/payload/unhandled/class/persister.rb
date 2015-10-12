# Connects an in-memory payload unhandled Metasploit Module's ruby Class to its persisted
# {Metasploit::Cache::Payload::Unhandled::Class}.
class Metasploit::Cache::Payload::Unhandled::Class::Persister < Metasploit::Cache::Module::Persister
  #
  # CONSTANTS
  #

  # Synchronizes attributes and associations from {#ephemeral} before persisting to database.
  SYNCHRONIZERS = [
      Metasploit::Cache::Module::Class::Persister::Rank
  ]

  #
  # Attributes
  #

  # The subclass of {Metasploit::Cache::Payload::Unhandled::Class} to use to look up {#persistent}.
  #
  # @return [Class<Metasploit::Cache::Payload::Unhandled::Class>]
  attr_accessor :persistent_class

  #
  # Resurrecting Attributes
  #

  # Cached metadata for this Class.
  #
  # @return [Metasploit::Cache::Payload::Unhandled::Class]
  resurrecting_attr_accessor(:persistent) {
    ActiveRecord::Base.connection_pool.with_connection {
      persistent_class.where(
          Metasploit::Cache::Module::Ancestor.arel_table[:real_path_sha1_hex_digest].eq(real_path_sha1_hex_digest)
      ).joins(:ancestor).readonly(false).first
    }
  }

  #
  # Validations
  #

  validates :persistent_class,
            presence: true

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
