# Class-level metadata for an auxiliary Metasploit Module.
class Metasploit::Cache::Auxiliary::Class < Metasploit::Cache::Direct::Class
  #
  # Associations
  #

  # Metadata for file that defined the ruby Class.
  belongs_to :ancestor,
             class_name: 'Metasploit::Cache::Auxiliary::Ancestor',
             inverse_of: :auxiliary_class

  # Metadata for instances of the class whose metadata this record stores.
  has_one :auxiliary_instance,
          class_name: 'Metasploit::Cache::Auxiliary::Instance',
          foreign_key: :auxiliary_class_id,
          inverse_of: :auxiliary_class

  # Reliability of Metasploit Module.
  belongs_to :rank,
             class_name: 'Metasploit::Cache::Module::Rank',
             inverse_of: :auxiliary_classes

  Metasploit::Concern.run(self)
end