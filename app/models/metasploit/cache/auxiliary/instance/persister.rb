# Connects an in-memory auxiliary Metasploit Module's ruby instance to its persisted
# {Metasploit::Cache::Auxiliary::Instance}.
class Metasploit::Cache::Auxiliary::Instance::Persister < Metasploit::Cache::Module::Persister
  extend ActiveSupport::Autoload

  autoload :Stance

  #
  # CONSTANTS
  #

  # Modules used to synchronize attributes and associations before persisting to database.
  SYNCHRONIZERS = [
      Metasploit::Cache::Persister.synchronizer(:description, :name),
      Metasploit::Cache::Actionable::Persister::Actions,
      self::Stance,
      Metasploit::Cache::Contributable::Persister::Contributions,
      Metasploit::Cache::Licensable::Persister::LicensableLicenses
  ]

  #
  # Instance Methods
  #

  protected

  # @return [ActiveRecord::Relation<Metasploit::Cache::Auxiliary::Instance>]
  def persistent_relation
    Metasploit::Cache::Auxiliary::Instance.joins(
        auxiliary_class: :ancestor
    ).where(
        Metasploit::Cache::Module::Ancestor.arel_table[:real_path_sha1_hex_digest].eq(real_path_sha1_hex_digest)
    )
  end

  private

  # {Metasploit::Cache::Module::Ancestor#real_path_sha1_hex_digest} used to resurrect {#auxiliary_instance}.
  #
  # @return [String]
  def real_path_sha1_hex_digest
    ephemeral.class.persister_by_source[:ancestor].real_path_sha1_hex_digest
  end

  # Tags log with {Metasploit::Cache::Auxiliary::Instance#auxiliary_class}
  # {Metasploit::Cache::Auxiliary::Class#ancestor} {Metasploit::Cache::Module::Ancestor#real_pathname}.
  #
  # @param auxiliary_instance [Metasploit::Cache::Auxiliary::Instance]
  # @yield [tagged_logger]
  # @yieldparam tagged_logger [ActiveSupport::TaggedLogger] {#logger} with
  #   {Metasploit::Cache::Module#Ancestor#real_pathname} tag.
  # @yieldreturn [void]
  # @return [void]
  def with_tagged_logger(auxiliary_instance, &block)
    Metasploit::Cache::Module::Ancestor::Persister.with_tagged_logger logger,
                                                                      auxiliary_instance.auxiliary_class.ancestor,
                                                                      &block
  end
end