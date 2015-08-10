# Join model for associating Metasploit::Cache::*::Instance objects with {Metasploit::Cache::License} objects.
# Implements a polymorphic association that the other models use for implementing `#licenses`.
class Metasploit::Cache::Licensable::License < ActiveRecord::Base
  include Metasploit::Cache::Batch::Descendant

  #
  # Attributes
  #

  # @!attribute license_id
  #   Primary key of the associated {Metasploit::Cache::License}
  #
  #   @return [Fixnum]

  # @!attribute licensable_type
  #   Model name with an associated license
  #
  #   @return [String]

  # @!attribute licensable_id
  #   Primary key of the associated object whose type is named by {#licensable_type}
  #
  #   @return [Fixnum]

  #
  # Associations
  #

  # Allows many classes to have a {Metasploit::Cache::License} object
  belongs_to :licensable,
             polymorphic: true

  # The license associated with the licensable
  #
  # @return [Metasploit::Cache::License]
  belongs_to :license,
             class_name: 'Metasploit::Cache::License',
             inverse_of: :licensable_licenses

  #
  # Validations
  #

  validates :license,
            presence: true
  validates :license_id,
            uniqueness: {
                scope: [
                    :licensable_type,
                    :licensable_id
                ],
                unless: :batched?
            }
  validates :licensable,
            presence: true

  #
  # Instance Methods
  #

  # @!method license_id=(license_id)
  #   Sets {#license_id} and invalidates cached {#license}, so it will be reloaded on next access.
  #
  #   @param license_id [Integer] Primary key of {Metasploit::Cache::License} to load into {#license}.
  #   @return [void]

  # @!method licensable_id=(licensable_id)
  #   Sets {#licensable_id} and invalidates cached {#licensable}, so it will be reloaded on next access.
  #
  #   @param licensable_id [Integer] Primary key of model named in {#licensable_type}.
  #   @return [void]

  # @!method licensable_type=(licensable_type)
  #   Sets {#licensable_type} and invalidates cached {#licensable}, so it will be reloaded on next access.
  #
  #   @param licensable_type [String] Name of a model that is licensed.
  #   @return [void]


  Metasploit::Concern.run(self)
end
