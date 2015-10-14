# Metadata from loading stager payload modules.
class Metasploit::Cache::Payload::Stager::Ancestor < Metasploit::Cache::Payload::Ancestor
  extend ActiveSupport::Autoload

  autoload :Handler

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

  # Handler metadata from ruby Module methods
  has_one :handler,
          autosave: true,
          class_name: 'Metasploit::Cache::Payload::Stager::Ancestor::Handler',
          dependent: :destroy,
          foreign_key: :payload_stager_ancestor_id,
          inverse_of: :payload_stager_ancestor

  # Path under which this module's {Metasploit::Cache::Module::Ancestor#relative_path} exists.
  belongs_to :parent_path,
             class_name: 'Metasploit::Cache::Module::Path',
             inverse_of: :stager_payload_ancestors

  # Class defined by this stager payload ancestor.
  has_one :stager_payload_class,
          class_name: 'Metasploit::Cache::Payload::Stager::Class',
          foreign_key: :ancestor_id,
          inverse_of: :ancestor

  #
  # Relative path restriction
  #

  Metasploit::Cache::Payload::Ancestor.restrict(self)

  Metasploit::Concern.run(self)
end