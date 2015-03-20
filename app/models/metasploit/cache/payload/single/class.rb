# Class-level metadata for an single payload Metasploit Module.
class Metasploit::Cache::Payload::Single::Class < Metasploit::Cache::Payload::Direct::Class
  #
  # Associations
  #

  # Metadata for file that defined the ruby Module.
  belongs_to :ancestor,
             class_name: 'Metasploit::Cache::Payload::Single::Ancestor',
             inverse_of: :single_payload_class

  # Reliability of Metasploit Module.
  belongs_to :rank,
             class_name: 'Metasploit::Cache::Module::Rank',
             inverse_of: :single_payload_classes

  Metasploit::Concern.run(self)
end