# Connects an in-memory stage payload Metasploit Module's ruby Class to its persisted
# {Metasploit::Cache::Payload::Staged::Class}.
class Metasploit::Cache::Payload::Staged::Class::Persister < Metasploit::Model::Base
  extend Metasploit::Cache::ResurrectingAttribute

  #
  # CONSTANTS
  #

  # Modules used to synchronize attributes and associations before persisting to database.
  SYNCHRONIZERS = []

  #
  # Attributes
  #

  # The Metasploit Module being cached.
  #
  # @return [Class]
  attr_accessor :ephemeral

  # Tagged logger to which to log {#persist} errors.
  #
  # @return [ActiveSupport::TaggedLogging]
  attr_accessor :logger

  #
  # Resurrecting Attributes
  #

  # Cached metadata for this Class.
  #
  # @return [Metasploit::Cache::Direct::Class]
  resurrecting_attr_accessor(:persistent) {
    ActiveRecord::Base.connection_pool.with_connection {
      Metasploit::Cache::Payload::Staged::Class.where_ancestor_real_path_sha1_hex_digests(
          stage: ancestor_real_path_sha1_hex_digest(:stage),
          stager: ancestor_real_path_sha1_hex_digest(:stager)
      ).readonly(false).first
    }
  }

  #
  # Validations
  #

  validates :ephemeral,
            presence: true
  validates :logger,
            presence: true

  #
  # Class Methods
  #

  # Tags log with {Metasploit::Cache::Module::Ancestor#real_pathname} from both
  #   {Metasploit::Cache::Payload::Staged::Class#payload_stage_instance}
  #   {Metasploit::Cache::Payload::Stage::Instance#payload_stage_class}
  #   {Metasploit::Cache::Payload::Stage::Class#ancestor} and
  #   {Metasploit::Cache::Payload::Staged::Class#payload_stager_instance}
  #   {Metasploit::Cache::Payload::Stager::Instance#payload_stager_class}
  #   {Metasploit::Cache::Payload::Stager::Class#ancestor}.
  #
  # @param logger [ActiveSupport::TaggedLogging]
  # @param payload_staged_class [Metasploit::Cache::Payload::Staged::Class]
  # @yield [tagged_logger]
  # @yieldparam tagged_logger [ActiveSupport::TaggedLogger] `logger` with
  #   {Metasploit::Cache::Module#Ancestor#real_pathname} tags.
  # @yieldreturn [void]
  # @return [void]
  def self.with_tagged_logger(logger, payload_staged_class, &block)
    tags = [
        payload_staged_class.payload_stage_instance.payload_stage_class.ancestor.real_pathname.to_s,
        payload_staged_class.payload_stager_instance.payload_stager_class.ancestor.real_pathname.to_s
    ]

    Metasploit::Cache::Logged.with_tagged_logger(ActiveRecord::Base, logger, *tags, &block)
  end

  #
  # Instance Methods
  #

  # {Metasploit::Cache::Module::Ancestor#real_path_sha1_hex_digest} from `ancestor` used to resurrect
  # {#payload_staged_class}.
  #
  # @param source [:stage, :stager] `:stage` to use the
  #   {Metasploit::Cache::Payload::Staged:Class#payload_stage_instance} or `:stager` to use the
  #   {Metasploit::Cache::Payload::Staged:Class#payload_stager_instance}
  #
  # @return [String]
  def ancestor_real_path_sha1_hex_digest(source)
    ephemeral.ancestor_by_source.fetch(source).persister_by_source.fetch(:ancestor).real_path_sha1_hex_digest
  end

  # @note This persister should be validated with `valid?` prior to calling {#persist} to ensure that {#logger} is
  #   present in case of error.
  # @note Validation errors for `payload_stage_class` will be logged as errors tagged with
  #   {Metasploit::Cache::Module::Ancestor#real_pathname} from both
  #   {Metasploit::Cache::Payload::Staged::Class#payload_stage_instance}
  #   {Metasploit::Cache::Payload::Stage::Instance#payload_stage_class}
  #   {Metasploit::Cache::Payload::Stage::Class#ancestor} and
  #   {Metasploit::Cache::Payload::Staged::Class#payload_stager_instance}
  #   {Metasploit::Cache::Payload::Stager::Instance#payload_stager_class}
  #   {Metasploit::Cache::Payload::Stager::Class#ancestor}.
  #
  # @param to [Metasploit::Cache::Payload::Stager::Class] Save cacheable data to
  #   {Metasploit::Cache::Payload::Stager::Class}.
  # @return [Metasploit::Cache::Payload::Stager::Class] `#persisted?` will be `false` if saving fails.
  def persist(to: persistent)
    persisted = nil

    ActiveRecord::Base.connection_pool.with_connection do
      with_tagged_loggger(to) do |tagged|
        persisted = Metasploit::Cache::Persister.persist destination: to,
                                                         logger: tagged,
                                                         source: ephemeral,
                                                         synchronizers: SYNCHRONIZERS
      end
    end

    persisted
  end

  private

  # Tags log with {Metasploit::Cache::Module::Ancestor#real_pathname} from both
  #   {Metasploit::Cache::Payload::Staged::Class#payload_stage_instance}
  #   {Metasploit::Cache::Payload::Stage::Instance#payload_stage_class}
  #   {Metasploit::Cache::Payload::Stage::Class#ancestor} and
  #   {Metasploit::Cache::Payload::Staged::Class#payload_stager_instance}
  #   {Metasploit::Cache::Payload::Stager::Instance#payload_stager_class}
  #   {Metasploit::Cache::Payload::Stager::Class#ancestor}.
  #
  # @param payload_staged_class [Metasploit::Cache::Payload::Staged::Class]
  # @yield [tagged_logger]
  # @yieldparam tagged_logger [ActiveSupport::TaggedLogger] {#logger} with
  #   {Metasploit::Cache::Module#Ancestor#real_pathname} tags.
  # @yieldreturn [void]
  # @return [void]
  def with_tagged_loggger(payload_staged_class, &block)
    self.class.with_tagged_logger(logger, payload_staged_class, &block)
  end
end
