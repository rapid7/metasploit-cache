# Connects an in-memory Metasploit Module's ruby Class to its persisted {Metasploit::Cache::Module::Class}.
class Metasploit::Cache::Direct::Class::Persister < Metasploit::Cache::Module::Persister
  extend ActiveSupport::Autoload

  autoload :Name

  #
  # CONSTANTS
  #

  SYNCHRONIZERS = [
      self::Name,
      Metasploit::Cache::Module::Class::Persister::Rank
  ]

  #
  # Attributes
  #

  # The subclass of {Metasploit::Cache::Direct::Class} to use to look up {#persistent}.
  #
  # @return [Class<Metasploit::Cache::Direct::Class>]
  attr_accessor :persistent_class

  #
  # Resurrecting Attributes
  #

  # Cached metadata for this Class.
  #
  # @return [Metasploit::Cache::Direct::Class]
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

  # {Metasploit::Cache::Module::Ancestor#real_path_sha1_hex_digest} used to resurrect {#persistent}.
  #
  # @return [String]
  def real_path_sha1_hex_digest
    ephemeral.persister_by_source[:ancestor].real_path_sha1_hex_digest
  end

  # Tags log with {Metasploit::Cache::Direct::Class#ancestor} {Metasploit::Cache::Module::Ancestor#real_pathname}.
  #
  # @param direct_class [Metasploit::Cache::Direct::Class, #ancestor]
  # @yield [tagged_logger]
  # @yieldparam tagged_logger [ActiveSupport::TaggedLogger] {#logger} with
  #   {Metasploit::Cache::Module#Ancestor#real_pathname} tag.
  # @yieldreturn [void]
  # @return [void]
  def with_tagged_logger(direct_class, &block)
    Metasploit::Cache::Module::Ancestor::Persister.with_tagged_logger(logger, direct_class.ancestor, &block)
  end
end
