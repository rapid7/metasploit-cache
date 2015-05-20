# Instance-level metadata for single payload Metasploit Modules
class Metasploit::Cache::Payload::Single::Instance < ActiveRecord::Base
  #
  #
  # Associations
  #
  #

  # The connection handler
  belongs_to :handler,
             class_name: 'Metasploit::Cache::Payload::Handler',
             inverse_of: :payload_single_instances

  # The class-level metadata for this single payload Metasploit Module.
  belongs_to :payload_single_class,
             class_name: 'Metasploit::Cache::Payload::Single::Class',
             inverse_of: :payload_single_instance

  # Joins {#platforms} to this single payload Metasploit Module.
  has_many :platformable_platforms,
           class_name: 'Metasploit::Cache::Platformable::Platform',
           dependent: :destroy,
           inverse_of: :platformable

  #
  # through: :platformable_platform
  #

  # Platforms this playload single Metasploit Module works on.
  has_many :platforms,
           class_name: 'Metasploit::Cache::Platform',
           through: :platformable_platforms

  #
  # Attributes
  #

  # @!attribute description
  #   The long-form human-readable description of this single payload Metasploit Module.
  #
  #   @return [String]

  # @!attribute name
  #   The human-readable name of this single payload Metasploit Module.  This can be thought of as the title or summary
  #   of the Metasploit Module.
  #
  #   @return [String]

  # @!attribute payload_single_class_id
  #   The foreign key for the {#payload_single_class} association.
  #
  #   @return [Integer]
  
  # @!attribute privileged
  #   Whether this payload requires privileged access to the remote machine.
  #
  #   @return [true] privileged access is granted.
  #   @return [false] privileged access is NOT granted.


  #
  # Validations
  #

  validates :description,
            presence: true
  validates :handler,
            presence: true
  validates :name,
            presence: true
  validates :payload_single_class,
            presence: true
  validates :payload_single_class_id,
            uniqueness: true
  validates :platformable_platforms,
            length: {
                minimum: 1
            }
  validates :privileged,
            inclusion: {
                in: [
                    false,
                    true
                ]
            }

  #
  # Instance Methods
  #

  # @!method description=(description)
  #   Sets {#description}.
  #
  #   @param description [String] The long-form human-readable description of this single payload Metasploit Module.
  #   @return [void]

  # @!method name=(name)
  #   Sets {#name}.
  #
  #   @param name [String] The human-readable name of this single payload Metasploit Module.  This can be thought of as
  #     the title or summary of the Metasploit Module.
  #   @return [void]

  # @!method payload_single_class_id=(payload_single_class_id)
  #   Sets {#payload_single_class_id} and causes cache of {#payload_single_class} to be invalidated and reloaded on next
  #   access.
  #
  #   @param payload_single_class_id [Integer]
  #   @return [void]

  # @!method privileged=(privileged)
  #   Sets {#privileged}.
  #
  #   @param priviliged [Boolean] `true` if privileged access is required; `false` if privileged access is not required.
  #   @return [void]

  Metasploit::Concern.run(self)
end