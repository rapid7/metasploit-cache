# Connects an in-memory Metasploit Module to its persisted {Metasploit::Cache::Module::Ancestor}.
class Metasploit::Cache::Module::Ancestor::Persister < Metasploit::Model::Base
  extend Metasploit::Cache::ResurrectingAttribute

  #
  # Attributes
  #

  # The Metasploit Module being cached.
  #
  # @return [Module]
  attr_accessor :ephemeral

  # Tagged logger to which to log {#persist_module_ancestor} errors.
  #
  # @return [ActiveSupport::TaggedLogging]
  attr_accessor :logger

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

  validates :ephemeral,
            presence: true
  validates :logger,
            presence: true
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

  # @note This persister should be validated with `valid?` prior to calling {#persist} to ensure that {#logger} is
  #   present in case of error.
  # @note Validation errors for `module_ancestor` will be logged as errors tagged with
  #   {Metasploit::Cache::Module::Ancestor#real_pathname}.
  #
  # Persists ephemeral data from {#ephemeral} and it's namespace to the persistent cache entry.
  #
  # @param to [Metasploit::Cache::Module::Ancestor] Save cacheable data to `module_ancestor`.
  # @return [Metasploit::Cache::Module::Ancestor] `#persisted?` will be `false` if saving fails
  def persist(to: persistent)
    persisted = nil

    ActiveRecord::Base.connection_pool.with_connection do
      with_tagged_logger(to) do |tagged|
        # Ensure that connection is only held temporary by Thread instead of being memoized to Thread
        persisted = Metasploit::Cache::Persister.persist destination: to,
                                                         logger: tagged,
                                                         source: ephemeral,
                                                         synchronizers: []
      end
    end

    persisted
  end

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