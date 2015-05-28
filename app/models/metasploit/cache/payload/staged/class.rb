# A staged payload Metasploit Module that combines a stager payload Metasploit Module that downloads a staged payload
# Metasploit Module.
#
# The stager and stage payload must be compatible.  A stager and stage are compatible if they share some subset of
# architectures and platforms.
class Metasploit::Cache::Payload::Staged::Class < ActiveRecord::Base
  #
  # Associations
  #

  # Stage payload Metasploit Module downloaded by stager.
  belongs_to :payload_stage_instance,
             class_name: 'Metasploit::Cache::Payload::Stage::Instance',
             inverse_of: :payload_staged_classes

  #
  # Validations
  #

  validates :payload_stage_instance,
            presence: true
end
