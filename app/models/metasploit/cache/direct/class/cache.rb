# Ephemeral Cache for connecting an in-memory Metasploit Module's ruby Class to its persisted
# {Metasploit::Cache::Module::Class} and {Metasploit::Cache::Module::Ancestor}.
class Metasploit::Cache::Direct::Class::Cache < Metasploit::Model::Base
  extend Metasploit::Cache::ResurrectingAttribute

  #
  # Attributes
  #

  # The ephemeral cache for just the {Metasploit::Cache::Module::Ancestor} for this Ruby Class.
  #
  # @return [Metasploit::Cache::Module::Ancestor::Ephemeral]
  attr_accessor :module_ancestor_ephemeral

  # The subclass of {Metasploit::Cache::Direct::Class} to use to look up {#direct_class}.
  #
  # @return [Class<Metasploit::Cache::Direct::Class>]
  attr_accessor :direct_class_class

  #
  # Resurrecting Attributes
  #

  # Cached metadata for this Class.
  #
  # @return [Metasploit::Cache::Direct::Class]
  resurrecting_attr_accessor :direct_class do
    ActiveRecord::Base.connection_pool.with_connection {
      direct_class_class.where(
          Metasploit::Cache::Module::Ancestor.arel_table[:real_path_sha1_hex_digest].eq(real_path_sha1_hex_digest)
      ).joins(:ancestor).readonly(false).first
    }
  end

  #
  # Validations
  #

  validates :direct_class_class,
            presence: true
  validates :module_ancestor_ephemeral,
            presence: true

  #
  # Instance Methods
  #

  delegate :logger,
           :metasploit_module,
           :module_ancestor,
           :real_path_sha1_hex_digest,
           to: :module_ancestor_ephemeral

  # @note Validation errors for `direct_class` will be logged as errors tagged with
  # {Metasploit::Cache::Module::Ancestor#real_pathname}/.
  #
  # @param to [Metasploit::Cache::Direct::Class] Save cacheable data to {Metasploit::Cache::Direct::Class}.
  # @return [Metasploit::Cache::Direct::Class] `#persisted?` will be `false` if saving fails.
  def persist_direct_class(to: direct_class)
    # Ensure that connection is only held temporarily by Thread instead of being memoized to Thread
    ActiveRecord::Base.connection_pool.with_connection do
      unless to.batched_save
        logger.tagged(module_ancestor.real_pathname.to_s) do |tagged|
          tagged.error {
            "Could not be persisted to #{to.class}: #{to.errors.full_messages.to_sentence}"
          }
        end
      end
    end

    to
  end
end