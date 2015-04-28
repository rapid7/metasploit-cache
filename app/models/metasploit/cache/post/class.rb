# Class-level metadata for an post Metasploit Module.
class Metasploit::Cache::Post::Class < Metasploit::Cache::Direct::Class
  #
  # Associations
  #

  # Metadata for file that defined the ruby Class.
  belongs_to :ancestor,
             class_name: 'Metasploit::Cache::Post::Ancestor',
             inverse_of: :post_class

  # Reliability of Metasploit Module.
  belongs_to :rank,
             class_name: 'Metasploit::Cache::Module::Rank',
             inverse_of: :post_classes

  Metasploit::Concern.run(self)
end