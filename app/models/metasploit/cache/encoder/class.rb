# Class-level metadata for an encoder  Metasploit Module.
class Metasploit::Cache::Encoder::Class < Metasploit::Cache::Direct::Class
  #
  # Associations
  #

  # Metadata for file that defined the ruby Class.
  belongs_to :ancestor,
             class_name: 'Metasploit::Cache::Encoder::Ancestor',
             inverse_of: :encoder_class
  
  # Metadata for instances of the class whose metadata this record stores.
  has_one :encoder_instance,
          class_name: 'Metasploit::Cache::Encoder::Instance',
          dependent: :destroy,
          foreign_key: :encoder_class_id,
          inverse_of: :encoder_class

  # Reliability of Metasploit Module.
  belongs_to :rank,
             class_name: 'Metasploit::Cache::Module::Rank',
             inverse_of: :auxiliary_classes

  Metasploit::Concern.run(self)
end