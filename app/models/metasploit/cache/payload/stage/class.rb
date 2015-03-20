# Class-level metadata for a stage payload Metasploit Module.
class Metasploit::Cache::Payload::Stage::Class < Metasploit::Cache::Payload::Direct::Class
  #
  # Associations
  #

  # Metadata for file that defined the ruby Module.
  belongs_to :ancestor,
             class_name: 'Metasploit::Cache::Payload::Stage::Ancestor',
             inverse_of: :stage_payload_class

  # Reliability of Metasploit Module.
  belongs_to :rank,
             class_name: 'Metasploit::Cache::Module::Rank',
             inverse_of: :stage_payload_classes

  Metasploit::Concern.run(self)
end