# Connects an in-memory Metasploit Module to its persisted {Metasploit::Cache::Module::Ancestor}.
class Metasploit::Cache::Module::Ancestor::Persister < Metasploit::Cache::Module::Persister
  #
  # CONSTANTS
  #

  # Modules used to synchronize attributes and associatons before persisting to database
  SYNCHRONIZERS = []

  #
  # Attributes
  #

  # The SHA1 hexdigest of the path where {#ephemeral} is defined on disk.
  #
  # @return [String]
  attr_accessor :real_path_sha1_hex_digest

  #
  # Resurrecting Attributes
  #

  # Cached metadata for this Module.
  #
  # @return [Metasploit::Cache::Module::Ancestor]
  resurrecting_attr_accessor(:persistent) {
    ActiveRecord::Base.connection_pool.with_connection {
      Metasploit::Cache::Module::Ancestor.where(real_path_sha1_hex_digest: real_path_sha1_hex_digest).first
    }
  }

  #
  # Validations
  #

  validates :real_path_sha1_hex_digest,
            presence: true

  #
  # Class Methods
  #

  # Tags log with {Metasploit::Cache::Module::Ancestor#real_pathname}.
  #
  # @param logger [ActiveSupport::TaggedLogger, #tagged] logger to tag.
  # @param module_ancestor [Metasploit::Cache::Module::Ancestor, #real_pathname]
  # @yield [tagged_logger]
  # @yieldparam tagged_logger [ActiveSupport::TaggedLogger] `logger` with
  #   {Metasploit::Cache::Module#Ancestor#real_pathname} tag.
  # @yieldreturn [void]
  # @return [void]
  def self.with_tagged_logger(logger, module_ancestor, &block)
    real_path = module_ancestor.real_pathname.to_s

    Metasploit::Cache::Logged.with_tagged_logger(ActiveRecord::Base, logger, real_path, &block)
  end

  #
  # Instance Methods
  #

  private

  # Tags log with {Metasploit::Cache::Module::Ancestor#real_pathname}.
  #
  # @param module_ancestor [Metasploit::Cache::Module::Ancestor, #real_pathname]
  # @yield [tagged_logger]
  # @yieldparam tagged_logger [ActiveSupport::TaggedLogger] {#logger} with
  #   {Metasploit::Cache::Module#Ancestor#real_pathname} tag.
  # @yieldreturn [void]
  # @return [void]
  def with_tagged_logger(module_ancestor, &block)
    self.class.with_tagged_logger(logger, module_ancestor, &block)
  end
end