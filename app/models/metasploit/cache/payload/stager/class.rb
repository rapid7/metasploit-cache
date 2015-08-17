# Class-level metadata for a stager payload Metasploit Module.
class Metasploit::Cache::Payload::Stager::Class < Metasploit::Cache::Payload::Direct::Class
  #
  # Associations
  #

  # Metadata for file that defined the ruby Module.
  belongs_to :ancestor,
             class_name: 'Metasploit::Cache::Payload::Stager::Ancestor',
             inverse_of: :stager_payload_class

  # Instance-level metadata for this stager payload Metasploit Module.
  has_one :payload_stager_instance,
          class_name: 'Metasploit::Cache::Payload::Stager::Instance',
          dependent: :destroy,
          foreign_key: :payload_stager_class_id,
          inverse_of: :payload_stager_class

  # Reliability of Metasploit Module.
  belongs_to :rank,
             class_name: 'Metasploit::Cache::Module::Rank',
             inverse_of: :stager_payload_classes

  Metasploit::Concern.run(self)
end