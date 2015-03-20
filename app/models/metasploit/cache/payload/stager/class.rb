# Class-level metadata for a stager payload Metasploit Module.
class Metasploit::Cache::Payload::Stager::Class < Metasploit::Cache::Payload::Direct::Class
  #
  # Associations
  #

  # Reliability of Metasploit Module.
  belongs_to :rank,
             class_name: 'Metasploit::Cache::Module::Rank',
             inverse_of: :stager_payload_classes
end