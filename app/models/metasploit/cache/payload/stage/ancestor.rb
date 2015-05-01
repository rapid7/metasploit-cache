# Metadata from loading stage payload modules.
class Metasploit::Cache::Payload::Stage::Ancestor < Metasploit::Cache::Payload::Ancestor
  #
  # CONSTANTS
  #

  # The valid value for {Metasploit::Cache::Payload::Ancestor#payload_type}
  PAYLOAD_TYPE = 'stage'
  # The directory under the {Metasploit::Cache::Module::Ancestor#module_type_directory} where stage payload ancestors
  # are stored.
  PAYLOAD_TYPE_DIRECTORY = PAYLOAD_TYPE.pluralize

  #
  # Associations
  #

  # Path under which this module's {Metasploit::Cache::Module::Ancestor#relative_path} exists.
  belongs_to :parent_path,
             class_name: 'Metasploit::Cache::Module::Path',
             inverse_of: :stage_payload_ancestors

  # Class defined by this stage payload ancestor.
  has_one :stage_payload_class,
          class_name: 'Metasploit::Cache::Payload::Stage::Class',
          foreign_key: :ancestor_id,
          inverse_of: :ancestor

  #
  # Relative path restriction
  #

  Metasploit::Cache::Payload::Ancestor.restrict(self)

  Metasploit::Concern.run(self)
end