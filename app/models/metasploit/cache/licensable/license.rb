# Join model for associating Metasploit::Cache::*::Instance objects with {Metasploit::Cache::License} objects.
# Implements a polymorphic association that the other models use for implementing `#licenses`.
class Metasploit::Cache::Licensable::License < ActiveRecord::Base

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
             class_name: "Metasploit::Cache::License"

  #
  # Validations
  #

  validates :license,
            presence: true

  validates :licensable_id,
            presence: true

  validates :licensable_type,
            presence: true

  Metasploit::Concern.run(self)
end
