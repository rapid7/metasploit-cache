# A staged payload Metasploit Module instance that combines a stager payload Metasploit Module that downloads a staged
# payload Metasploit Module.
#
# The stager and stage payload must be compatible.  A stager and stage are compatible if they share some subset of
# architectures and platforms.
class Metasploit::Cache::Payload::Staged::Instance < ActiveRecord::Base
  extend ActiveSupport::Autoload

  include Metasploit::Cache::Batch::Root

  autoload :Ephemeral

  #
  # Associations
  #

  # The staged payload Metasploit Module class cache for this payload Metasploit Module instance cache.
  belongs_to :payload_staged_class,
             class_name: 'Metasploit::Cache::Payload::Staged::Class',
             foreign_key: :payload_staged_class_id,
             inverse_of: :payload_staged_instance

  #
  # Validations
  #

  validates :payload_staged_class,
            presence: true
  validates :payload_staged_class_id,
            uniqueness: true

  #
  # Class Methods
  #

  # Scope matching {Metasploit::Cache::Payload::Staged::Instance} where the ancestors have the given
  # {Metasploit::Cache::Module::Ancestor#real_path_sha1_hex_digest}.
  #
  # @param stage [String] {Metasploit::Cache::Module::Ancestor#real_path_sha1_hex_digest} for
  #   {Metasploit::Cache::Payload::Stage::Ancestor}.
  # @param stager [String] {Metasploit::Cache::Module::Ancestor#real_path_sha1_hex_digest} for
  #   {Metasploit::Cache::Payload::Stage::Ancestor}.
  # @return [ActiveRecord::Relation<Metasploit::Cache::Payload::Staged::Class>]
  def self.where_ancestor_real_path_sha1_hex_digests(stage:, stager:)
    joins(:payload_staged_class).merge(
        Metasploit::Cache::Payload::Staged::Class.where_ancestor_real_path_sha1_hex_digests(
            stage: stage,
            stager: stager
        )
    )
  end

  #
  # Instance Methods
  #

  # @!method payload_staged_class_id
  #   The foreign key for {#payload_staged_class}.
  #
  #   @return [Integer]
end