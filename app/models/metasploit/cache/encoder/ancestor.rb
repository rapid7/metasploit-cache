# Metadata from loading encoder Metasploit Modules.
class Metasploit::Cache::Encoder::Ancestor < Metasploit::Cache::Module::Ancestor
  #
  # CONSTANTS
  #

  # The valid value for {Metasploit::Cache::Module::Ancestor#module_type}
  MODULE_TYPE = Metasploit::Cache::Module::Type::ENCODER
  # The directory under which {#parent_path} where encoder ancestors are stored.
  MODULE_TYPE_DIRECTORY = MODULE_TYPE.pluralize

  #
  # Associations
  #

  # Class defined by this encoder ancestor.
  has_one :encoder_class,
          class_name: 'Metasploit::Cache::Encoder::Class',
          foreign_key: :ancestor_id,
          inverse_of: :ancestor

  # Path under which this module's {Metasploit::Cache::Module::Ancestor#relative_path} exists.
  belongs_to :parent_path,
             class_name: 'Metasploit::Cache::Module::Path',
             inverse_of: :encoder_ancestors

  #
  # Relative path restriction
  #

  Metasploit::Cache::Module::Ancestor.restrict(self)

  Metasploit::Concern.run(self)
end