# Class-level metadata for an single payload Metasploit Module.
class Metasploit::Cache::Payload::Single::Class < Metasploit::Cache::Payload::Direct::Class
  #
  # Associations
  #

  # Metadata for file that defined the ruby Module.
  belongs_to :ancestor,
             class_name: 'Metasploit::Cache::Payload::Single::Ancestor',
             inverse_of: :single_payload_class

  # Instance-level metadata for this single payload Metasploit Module.
  has_one :payload_single_instance,
          class_name: 'Metasploit::Cache::Payload::Single::Instance',
          dependent: :destroy,
          inverse_of: :payload_single_class

  # Reliability of Metasploit Module.
  belongs_to :rank,
             class_name: 'Metasploit::Cache::Module::Rank',
             inverse_of: :single_payload_classes

  Metasploit::Concern.run(self)
end