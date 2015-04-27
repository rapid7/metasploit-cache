# Class-level metadata for an nop Metasploit Module.
class Metasploit::Cache::Nop::Class < Metasploit::Cache::Direct::Class
  #
  # Associations
  #

  # Metadata for file that defined the ruby Class.
  belongs_to :ancestor,
             class_name: 'Metasploit::Cache::Nop::Ancestor',
             inverse_of: :nop_class

  # Instance level metadata for this nop Metasploit Module.
  has_one :nop_instance,
          class_name: 'Metasploit::Cache::Nop::Instance',
          dependent: :destroy,
          inverse_of: :nop_class

  # Reliability of Metasploit Module.
  belongs_to :rank,
             class_name: 'Metasploit::Cache::Module::Rank',
             inverse_of: :nop_classes

  Metasploit::Concern.run(self)
end