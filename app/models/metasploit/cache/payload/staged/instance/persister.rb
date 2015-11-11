# Connects an in-memory staged payload Metasploit Module's ruby instance to its persisted
# {Metasploit::Cache::Payload::Staged::Instance}
class Metasploit::Cache::Payload::Staged::Instance::Persister < Metasploit::Cache::Module::Persister
  #
  # CONSTANTS
  #

  # Modules used to synchronize attributes and associatons before persisting to database
  SYNCHRONIZERS = []

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

  protected

  # @return [ActiveRecord::Relation<Metasploit::Cache::Payload::Staged::Instance>]
  def persistent_relation
    Metasploit::Cache::Payload::Staged::Instance.where_ancestor_real_path_sha1_hex_digests(
        stage: ancestor_real_path_sha1_hex_digest(:stage),
        stager: ancestor_real_path_sha1_hex_digest(:stager)
    )
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