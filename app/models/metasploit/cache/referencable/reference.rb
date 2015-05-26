# Join model linking Metasploit cache objects such as Exploit and Post instances to external references
# such as those from the CVE database (https://cve.mitre.org)
class Metasploit::Cache::Referencable::Reference < ActiveRecord::Base

  #
  # Attributes
  #

  # @!attribute referencable_type
  #   Model name with an associated reference
  #
  #   @return [String]

  # @!attribute referencable_id
  #   Primary key of the associated object whose type is named by {#referencable_type}
  #
  #   @return [Integer]

  # @!attribute reference_id
  #   Primary key of the associated {Metasploit::Cache::Reference}
  #
  #   @return [Integer]

  #
  # Associations
  #

  # Allows many classes to have a {Metasploit::Cache::Reference} object
  belongs_to :referencable,
             polymorphic: true

  # The reference associated with the referencable
  belongs_to :reference,
             class_name: 'Metasploit::Cache::Reference',
             inverse_of: :referencable_references

  #
  # Validations
  #

  validates :reference,
            presence: true
  validates :reference_id,
            uniqueness: {
              scope: [
                       :referencable_type,
                       :referencable_id
                     ]
            }
  validates :referencable,
            presence: true

  #
  # Instance Methods
  #

  # @!method referencable_id=(referencable_id)
  #   Sets {#referencable_id} and invalidates cached {#referencable}, so it will be reloaded on next access.
  #
  #   @param referencable_id [Integer] Primary key of model named in {#referencable_type}.
  #   @return [void]

  # @!method referencable_type=(referencable_type)
  #   Sets {#referencable_type} and invalidates cached {#referencable}, so it will be reloaded on next access.
  #
  #   @param referencable_type [String] Name of a model that is referenced.
  #   @return [void]

  # @!method reference_id=(reference_id)
  #   Sets {#reference_id} and invalidates cached {#reference}, so it will be reloaded on next access.
  #
  #   @param reference_id [Integer] Primary key of {Metasploit::Cache::Reference} to load into {#reference}.
  #   @return [void]

  Metasploit::Concern.run(self)
end