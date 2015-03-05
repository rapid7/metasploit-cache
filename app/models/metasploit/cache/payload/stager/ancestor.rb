class Metasploit::Cache::Payload::Stager::Ancestor < Metasploit::Cache::Payload::Ancestor
  #
  # CONSTANTS
  #

  # The valid value for {Metasploit::Cache::Payload::Ancestor#payload_type}
  PAYLOAD_TYPE = 'stager'
  # The directory under the {Metasploit::Cache::Module::Ancestor#module_type_directory} where stager payload ancestors
  # are stored.
  PAYLOAD_TYPE_DIRECTORY = PAYLOAD_TYPE.pluralize

  #
  # Associations
  #

  # Path under which this module's {Metasploit::Cache::Module::Ancestor#relative_path} exists.
  belongs_to :parent_path,
             class_name: 'Metasploit::Cache::Module::Path',
             inverse_of: :stager_payload_ancestors

  #
  # Relative path restriction
  #

  Metasploit::Cache::Payload::Ancestor.restrict(self)

  Metasploit::Concern.run(self)
end