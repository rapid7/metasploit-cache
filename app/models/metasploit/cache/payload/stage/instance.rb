# Instance-level metadata for stage payload Metasploit Module
class Metasploit::Cache::Payload::Stage::Instance < ActiveRecord::Base
  #
  # Associations
  #

  # The class-level metadata for this stage payload Metasploit Module.
  belongs_to :payload_stage_class,
             class_name: 'Metasploit::Cache::Payload::Stage::Class',
             inverse_of: :payload_stage_instance
  
  #
  # Attributes
  #

  # @!attribute description
  #   The long-form human-readable description of this stage payload Metasploit Module.
  #
  #   @return [String]

  # @!attribute name
  #   The human-readable name of this stage payload Metasploit Module.  This can be thought of as the title or summary
  #   of the Metasploit Module.
  #
  #   @return [String]

  # @!attribute payload_stage_class_id
  #   The foreign key for the {#payload_stage_class} association.
  #
  #   @return [Integer]

  # @!attribute privileged
  #   Whether this payload requires privileged access to the remote machine.
  #
  #   @return [true] privileged access is required.
  #   @return [false] privileged access is NOT required.

  #
  # Validations
  #

  validates :description,
            presence: true
  validates :name,
            presence: true
  validates :payload_stage_class,
            presence: true
  validates :payload_stage_class_id,
            uniqueness: true

  Metasploit::Concern.run(self)
end