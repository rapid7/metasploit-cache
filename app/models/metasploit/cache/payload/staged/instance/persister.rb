# Connects an in-memory staged payload Metasploit Module's ruby instance to its persisted
# {Metasploit::Cache::Payload::Staged::Instance}
class Metasploit::Cache::Payload::Staged::Instance::Persister < Metasploit::Model::Base
  extend Metasploit::Cache::ResurrectingAttribute

  #
  # Attributes
  #

  # The in-memory staged payload Metasploit Module instance being cached.
  #
  # @return [Object]
  attr_accessor :ephemeral

  # Tagged logger to which to log {#persist} errors.
  #
  # @return [ActiveSupport::TaggerLogger]
  attr_accessor :logger

  #
  # Resurrecting Attributes
  #

  # Cached metadata for this {#ephemeral}.
  #
  # @return [Metasploit::Cache::Payload::Staged::Instance]
  resurrecting_attr_accessor(:persistent) {
    ActiveRecord::Base.connection_pool.with_connection {
      Metasploit::Cache::Payload::Staged::Instance.where_ancestor_real_path_sha1_hex_digests(
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
  # Instance Methods
  #

  # {Metasploit::Cache::Module::Ancestor#real_path_sha1_hex_digest} from `ancestor` used to resurrect
  # {#payload_staged_instance}.
  #
  # @param source [:stage, :stager] `:stage` to use the
  #   {Metasploit::Cache::Payload::Stage::Instance#payload_stage_class}
  #   {Metasploit::Cache::Payload::Staged:Class#payload_stage_instance} or `:stager` to use the
  #   {Metasploit::Cache::Payload::Stage::Instance#payload_stage_class}
  #   {Metasploit::Cache::Payload::Staged:Class#payload_stager_instance}
  #
  # @return [String]
  def ancestor_real_path_sha1_hex_digest(source)
    ephemeral.class.persister_by_source.fetch(:class).ancestor_real_path_sha1_hex_digest(source)
  end

  # @note This persister should be validated with `#valid?` prior to calling {#persist} to ensure that {#logger} is
  #   present in case of error.
  # @note Validation errors for `payload_stage_class` will be logged as errors tagged with
  #   {Metasploit::Cache::Module::Ancestor#real_pathname} from both
  #   {Metasploit::Cache;:Payload::Staged::Instance#payload_staged_class}
  #   {Metasploit::Cache::Payload::Staged::Class#payload_stage_instance}
  #   {Metasploit::Cache::Payload::Stage::Instance#payload_stage_class}
  #   {Metasploit::Cache::Payload::Stage::Class#ancestor} and
  #   {Metasploit::Cache;:Payload::Staged::Instance#payload_staged_class}
  #   {Metasploit::Cache::Payload::Staged::Class#payload_stager_instance}
  #   {Metasploit::Cache::Payload::Stager::Instance#payload_stager_class}
  #   {Metasploit::Cache::Payload::Stager::Class#ancestor}.
  #
  # @param to [Metasploit::Cache::Payload::Staged::Instance] Sve cacheable data to {Metasploit::Cache::Payload::Staged::Instance}.
  #   Giving `to` saves a database lookup if {#payload_staged_instance} is not loaded.
  # @return [Metasploit::Cache:Payload::Staged::Instance] `#persisted?` will be `false` if saving fails.
  def persist(to: persistent)
    with_tagged_logger(to) do |tagged|
      # Ensure that connection is only held temporarily by Thread instead of being memoized to Thread
      saved = ActiveRecord::Base.connection_pool.with_connection {
        to_class = to.class

        to_class.isolation_level(:serializable) {
          to_class.transaction {
            to.batched_save
          }
        }
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
  #   {Metasploit::Cache;:Payload::Staged::Instance#payload_staged_class}
  #   {Metasploit::Cache::Payload::Staged::Class#payload_stage_instance}
  #   {Metasploit::Cache::Payload::Stage::Instance#payload_stage_class}
  #   {Metasploit::Cache::Payload::Stage::Class#ancestor} and
  #   {Metasploit::Cache;:Payload::Staged::Instance#payload_staged_class}
  #   {Metasploit::Cache::Payload::Staged::Class#payload_stager_instance}
  #   {Metasploit::Cache::Payload::Stager::Instance#payload_stager_class}
  #   {Metasploit::Cache::Payload::Stager::Class#ancestor}.
  #
  # @param payload_staged_instance [Metasploit::Cache::Payload::Staged::Instance]
  # @yield [tagged_logger]
  # @yieldparam tagged_logger [ActiveSupport::TaggedLogger] {#logger} with
  #   {Metasploit::Cache::Module#Ancestor#real_pathname} tags.
  # @yieldreturn [void]
  # @return [void]
  def with_tagged_logger(payload_staged_instance, &block)
    Metasploit::Cache::Payload::Staged::Class::Persister.with_tagged_logger(
        logger,
        payload_staged_instance.payload_staged_class,
        &block
    )
  end
end