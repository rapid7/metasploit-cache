# Metadata from loading post Metasploit Modules.
class Metasploit::Cache::Post::Ancestor < Metasploit::Cache::Module::Ancestor
  #
  # CONSTANTS
  #

  # The valid value for {Metasploit::Cache::Module::Ancestor#module_type}.
  MODULE_TYPE = Metasploit::Cache::Module::Type::POST
  # The directory under {#parent_path} where post ancestors are stored.
  MODULE_TYPE_DIRECTORY = MODULE_TYPE

  #
  # Associations
  #

  # Path under which this module's {Metasploit::Cache::Module::Ancestor#relative_path} exists.
  belongs_to :parent_path,
             class_name: 'Metasploit::Cache::Module::Path',
             inverse_of: :post_ancestors

  # Class defined by this post ancestor.
  has_one :post_class,
          class_name: 'Metasploit::Cache::Post::Class',
          foreign_key: :ancestor_id,
          inverse_of: :ancestor

  #
  # Relative path restrictions
  #

  Metasploit::Cache::Module::Ancestor.restrict(self)

  Metasploit::Concern.run(self)
end