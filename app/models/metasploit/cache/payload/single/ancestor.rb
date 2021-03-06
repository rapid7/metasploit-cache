# Metadata from loading single payload modules.
class Metasploit::Cache::Payload::Single::Ancestor < Metasploit::Cache::Payload::Ancestor
  #
  # CONSTANTS
  #

  # The valid value for {Metasploit::Cache::Payload::Ancestor#payload_type}
  PAYLOAD_TYPE = 'single'
  # The directory under the {Metasploit::Cache::Module::Ancestor#module_type_directory} where single payload ancestors
  # are stored.
  PAYLOAD_TYPE_DIRECTORY = PAYLOAD_TYPE.pluralize

  #
  # Associations
  #

  # Path under which this module's {Metasploit::Cache::Module::Ancestor#relative_path} exists.
  belongs_to :parent_path,
             class_name: 'Metasploit::Cache::Module::Path',
             inverse_of: :single_payload_ancestors

  # Class defined by this single payload ancestor.
  has_one :payload_single_unhandled_class,
          class_name: 'Metasploit::Cache::Payload::Single::Unhandled::Class',
          foreign_key: :ancestor_id,
          inverse_of: :ancestor

  #
  # Relative path restriction
  #

  Metasploit::Cache::Payload::Ancestor.restrict(self)

  Metasploit::Concern.run(self)
end