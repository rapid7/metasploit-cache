# Metadata from loading nop Metasploit Modules.
class Metasploit::Cache::Nop::Ancestor < Metasploit::Cache::Module::Ancestor
  #
  # CONSTANTS
  #

  # The valid value for {Metasploit::Cache::Module::Ancestor#module_type}
  MODULE_TYPE = Metasploit::Cache::Module::Type::NOP
  # The directory under {#parent_path} where nop ancestors are stored.
  MODULE_TYPE_DIRECTORY = MODULE_TYPE.pluralize

  #
  # Associations
  #

  # Class defined by this nop ancestor.
  has_one :nop_class,
          class_name: 'Metasploit::Cache::Nop::Class',
          foreign_key: :ancestor_id,
          inverse_of: :ancestor

  # Path under which this module's {Metasploit::Cache::Module::Ancestor#relative_path} exists.
  belongs_to :parent_path,
             class_name: 'Metasploit::Cache::Module::Path',
             inverse_of: :nop_ancestors

  #
  # Relative path restriction
  #

  Metasploit::Cache::Module::Ancestor.restrict(self)

  Metasploit::Concern.run(self)
end