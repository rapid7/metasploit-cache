# Ephemeral Cache for connecting an in-memory stage payload Metasploit Module's ruby Class to its persisted
# {Metasploit::Cache::Payload::Staged::Class}.
class Metasploit::Cache::Payload::Staged::Class::Ephemeral < Metasploit::Model::Base
  extend Metasploit::Cache::ResurrectingAttribute

  #
  # Attributes
  #

  # Tagged logger to which to log {#persist_direct_class} errors.
  #
  # @return [ActiveSupport::TaggedLogging]
  attr_accessor :logger

  # The Metasploit Module being cached.
  #
  # @return [Class]
  attr_accessor :payload_staged_metasploit_module_class

  #
  # Resurrecting Attributes
  #

  # Cached metadata for this Class.
  #
  # @return [Metasploit::Cache::Direct::Class]
  resurrecting_attr_accessor :payload_staged_class do
    ActiveRecord::Base.connection_pool.with_connection {
      Metasploit::Cache::Payload::Staged::Class.where_ancestor_real_path_sha1_hex_digests(
          stage: ancestor_real_path_sha1_hex_digest(:stage),
          stager: ancestor_real_path_sha1_hex_digest(:stager)
      ).readonly(false).first
    }
  end

  #
  # Validations
  #

  validates :logger,
            presence: true
  validates :payload_staged_metasploit_module_class,
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
  def self.with_payload_staged_class_tag(logger, payload_staged_class, &block)
    tags = ActiveRecord::Base.connection_pool.with_connection {
      [
          payload_staged_class.payload_stage_instance.payload_stage_class.ancestor.real_pathname.to_s,
          payload_staged_class.payload_stager_instance.payload_stager_class.ancestor.real_pathname.to_s
      ]
    }

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
    payload_staged_metasploit_module_class.ancestor_by_source.fetch(source).ephemeral_cache_by_source.fetch(:ancestor).real_path_sha1_hex_digest
  end

  # @note This ephemeral cache should be validated with `valid?` prior to calling {#persist} to ensure that {#logger} is
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
  def persist(to: payload_staged_class)
    with_payload_staged_class_tag(to) do |tagged|
      # Ensure that connection is only held temporarily by Thread instead of being memoized to Thread
      saved = ActiveRecord::Base.connection_pool.with_connection {
        to.batched_save
      }

      unless saved
        tagged.error {
          "Could not be persisted to #{to.class}: #{to.errors.full_messages.to_sentence}"
        }
      end
    end

    to
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
  def with_payload_staged_class_tag(payload_staged_class, &block)
    self.class.with_payload_staged_class_tag(logger, payload_staged_class, &block)
  end
end
