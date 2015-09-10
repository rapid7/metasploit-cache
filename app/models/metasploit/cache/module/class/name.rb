# The name of a `Metasploit::Cache::**::Class` used to load it.  A Metasploit Module class has 3 'name' attributes,
# full name, reference name, and name.  Name is odd in that it is human-readable prose like description.  Full name and
# reference name are related: full name is `{#module_type}/{#reference_name}`.  Full name is used to `use` a Metasploit
# Module in `msfconsole`, so this class helps map names used in `msfconsole` back to the
class Metasploit::Cache::Module::Class::Name < ActiveRecord::Base
  include Metasploit::Cache::Batch::Descendant

  #
  # Associations
  #

  # The {Metasploit::Cache::Auxiliary::Class}, {Metasploit::Cache::Encoder::Class}, {Metasploit::Cache::Exploit::Class},
  # {Metasploit::Cache::Nop::Class}, {Metasploit::Cache::Payload::Single::Class},
  # {Metasploit::Cache::Payload::Staged::Class}, or {Metasploit::Cache::Post::Class} with this name.
  #
  # @return [Metasploit::Cache::Auxiliary::Class, Metasploit::Cache::Encoder::Class, Metasploit::Cache::Exploit::Class, Metasploit::Cahe::Nop::Class, Metasploit::Cache::Payload::Single::Class, Metasploit::Cache::Payload::Staged::Class, Metasploit::Cache::Post::Class, #module_class_name]
  belongs_to :module_class,
             foreign_key: :module_class_id,
             inverse_of: :name,
             polymorphic: true

  Metasploit::Cache::SingleTablePolymorphic.use(self)

  #
  # Attributes
  #

  # @!attribute module_type
  #   The type of the {#module_class}.
  #
  #   @return ['auxiliary', 'encoder', 'exploit', 'nop', 'payload', 'post']

  # @!attribute reference
  #   The name of the {#module_class} scoped to the {#module_type}.
  #
  #   @return [String]

  #
  # Validations
  #

  validates :module_class,
            presence: true
  validates :module_class_id,
            uniqueness: {
                scope: :module_class_type,
                unless: :batched?
            }
  validates :module_type,
            presence: true
  validates :reference,
            presence: true,
            uniqueness: {
                scope: :module_type,
                unless: :batched?
            }
end