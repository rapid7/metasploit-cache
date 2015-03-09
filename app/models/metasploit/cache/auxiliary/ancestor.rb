# Metadata from loading auxiliary modules.
class Metasploit::Cache::Auxiliary::Ancestor < Metasploit::Cache::Module::Ancestor
  #
  # CONSTANTS
  #

  # The valid value for {Metasploit::Cache::Module::Ancestor#module_type}.
  MODULE_TYPE = Metasploit::Cache::Module::Type::AUX
  # The directory under {#parent_path} where auxiliary ancestors are stored.
  MODULE_TYPE_DIRECTORY = MODULE_TYPE

  #
  # Associations
  #

  # Class defined by this auxiliary ancestor.
  has_one :auxiliary_class,
          class_name: 'Metasploit::Cache::Auxiliary::Class',
          foreign_key: :ancestor_id,
          inverse_of: :ancestor

  # Path under which this module's {Metasploit::Cache::Module::Ancestor#relative_path} exists.
  belongs_to :parent_path,
             class_name: 'Metasploit::Cache::Module::Path',
             inverse_of: :auxiliary_ancestors

  #
  # Relative path restriction
  #

  Metasploit::Cache::Module::Ancestor.restrict(self)

  Metasploit::Concern.run(self)
end