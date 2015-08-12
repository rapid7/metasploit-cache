# Class-level metadata for a stage payload Metasploit Module.
class Metasploit::Cache::Payload::Stage::Class < Metasploit::Cache::Payload::Direct::Class
  #
  # Associations
  #

  # Metadata for file that defined the ruby Module.
  belongs_to :ancestor,
             class_name: 'Metasploit::Cache::Payload::Stage::Ancestor',
             inverse_of: :stage_payload_class

  # Instance-level metadata for this stage payload Metasploit Module.
  has_one :payload_stage_instance,
          class_name: 'Metasploit::Cache::Payload::Stage::Instance',
          dependent: :destroy,
          foreign_key: :payload_stage_class_id,
          inverse_of: :payload_stage_class

  # Reliability of Metasploit Module.
  belongs_to :rank,
             class_name: 'Metasploit::Cache::Module::Rank',
             inverse_of: :stage_payload_classes

  Metasploit::Concern.run(self)
end