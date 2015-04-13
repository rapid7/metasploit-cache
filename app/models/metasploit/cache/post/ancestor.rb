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

  #
  # Relative path restrictions
  #

  Metasploit::Cache::Module::Ancestor.restrict(self)

  Metasploit::Concern.run(self)
end