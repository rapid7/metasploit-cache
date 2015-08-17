# A staged payload Metasploit Module instance that combines a stager payload Metasploit Module that downloads a staged
# payload Metasploit Module.
#
# The stager and stage payload must be compatible.  A stager and stage are compatible if they share some subset of
# architectures and platforms.
class Metasploit::Cache::Payload::Staged::Instance < ActiveRecord::Base
  include Metasploit::Cache::Batch::Root

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
  # Instance Methods
  #

  # @!method payload_staged_class_id
  #   The foreign key for {#payload_staged_class}.
  #
  #   @return [Integer]
end