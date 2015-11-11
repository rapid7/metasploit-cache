# Connects an in-memory single payload Metasploit Module's ruby instance with handler mixed-in to its persisted
# {Metasploit::Cache::Payload::Single::Handled::Instance}
class Metasploit::Cache::Payload::Single::Handled::Instance::Persister < Metasploit::Cache::Module::Persister
  #
  # CONSTANTS
  #

  # Modules used to synchronize attributes and associations before persisting to database.
  SYNCHRONIZERS = []

  #
  # Instance Methods
  #

  protected

  # @return [ActiveRecord::Relation<Metasploit::Cache::Payload::Single::Handled::Instance>]
  def persistent_relation
    Metasploit::Cache::Payload::Single::Handled::Instance.joins(
        payload_single_handled_class: {
            payload_single_unhandled_instance: {
                payload_single_unhandled_class: :ancestor
            }
        }
    ).where(
        Metasploit::Cache::Module::Ancestor.arel_table[:real_path_sha1_hex_digest].eq(real_path_sha1_hex_digest)
    )
  end

  private

  # {Metasploit::Cache::Module::Ancestor#real_path_sha1_hex_digest} used to resurrect {#payload_single_handled_class}.
  #
  # @return [String]
  def real_path_sha1_hex_digest
    ephemeral.class.persister_by_source.fetch(:ancestor).real_path_sha1_hex_digest
  end

  # Tags log with {Metasploit::Cache::Payload::Single::Handled::Class#payload_single_unhandled_instance}
  # {Metasploit::Cache::Payload::Single::Handled::Class#payload_single_unhandled_instance}
  # {Metasploit::Cache::Payload::Single::Unhandled::Instance#payload_single_unhandled_class}
  # {Metasploit::Cache::Payload::Single::Unhandled::Class#ancestor} {Metasploit::Cache::Module::Ancestor#real_pathname}.
  #
  # @param payload_single_handled_instance [Metasploit::Cache::Payload::Single::Handled::Instance]
  # @yield [tagged_logger]
  # @yieldparam tagged_logger [ActiveSupport::TaggedLogger] {#logger} with
  #   {Metasploit::Cache::Module#Ancestor#real_pathname} tags.
  # @yieldreturn [void]
  # @return [void]
  def with_tagged_logger(payload_single_handled_instance, &block)
    payload_single_handled_class = payload_single_handled_instance.payload_single_handled_class

    Metasploit::Cache::Payload::Single::Handled::Class::Persister.with_tagged_logger(
        logger,
        payload_single_handled_class,
        &block
    )
  end
end