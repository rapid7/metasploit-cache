# A staged payload Metasploit Module that combines a stager payload Metasploit Module that downloads a staged payload
# Metasploit Module.
#
# The stager and stage payload must be compatible.  A stager and stage are compatible if they share some subset of
# architectures and platforms.
class Metasploit::Cache::Payload::Staged::Class < ActiveRecord::Base
  #
  # Associations
  #

  # Stage payload Metasploit Module downloaded by {#payload_stager_instance}.
  belongs_to :payload_stage_instance,
             class_name: 'Metasploit::Cache::Payload::Stage::Instance',
             inverse_of: :payload_staged_classes

  # Stager payload Metasploit Module that exploit Metasploit Module runs on target system and which then downloads
  # {#payload_stage_instance stage payload Metasploit Module} to complete this staged payload Metasploit Module on the
  # target system.
  belongs_to :payload_stager_instance,
             class_name: 'Metasploit::Cache::Payload::Stager::Instance',
             inverse_of: :payload_staged_classes

  #
  # Attributes
  #

  # @!attribute payload_stage_instance_id
  #   Foreign key for {#payload_stage_instance}.
  #
  #   @return [Integer]

  # @!attribute payload_stager_instance_id
  #   Foreign key for {#payload_stager_instance}.
  #
  #   @return [Integer]

  #
  # Validations
  #

  validates :payload_stage_instance,
            presence: true

  validates :payload_stage_instance_id,
            uniqueness: {
                scope: :payload_stager_instance_id
            }

  validates :payload_stager_instance,
            presence: true

  #
  # Instance Methods
  #
  
  # @!method payload_stage_instance_id=(payload_stage_instance_id)
  #   Sets {#payload_stage_instance_id} and invalidates cached {#payload_stage_instance} so it is reloaded on next
  #   access.
  #
  #   @param payload_stage_instance_id [Integer]
  #   @return [void]
  
  # @!method payload_stager_instance_id=(payload_stager_instance_id)
  #   Sets {#payload_stager_instance_id} and invalidates cached {#payload_stager_instance} so it is reloaded on next
  #   access.
  #
  #   @param payload_stager_instance_id [Integer]
  #   @return [void] 
  
  Metasploit::Concern.run(self)
end
