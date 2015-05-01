# Class-level metadata for a stager payload Metasploit Module.
class Metasploit::Cache::Payload::Stager::Class < Metasploit::Cache::Payload::Direct::Class
  #
  # Associations
  #

  # Metadata for file that defined the ruby Module.
  belongs_to :ancestor,
             class_name: 'Metasploit::Cache::Payload::Stager::Ancestor',
             inverse_of: :stager_payload_class

  # Reliability of Metasploit Module.
  belongs_to :rank,
             class_name: 'Metasploit::Cache::Module::Rank',
             inverse_of: :stager_payload_classes

  Metasploit::Concern.run(self)
end