# Instance-level metadata for a nop Metasploit Module
class Metasploit::Cache::Nop::Instance < ActiveRecord::Base
  #
  # Associations
  #

  # The class level metadata for this nop Metasploit Module.
  belongs_to :nop_class,
             class_name: 'Metasploit::Cache::Nop::Class',
             inverse_of: :nop_instance

  #
  # Attributes
  #

  # @!attribute description
  #   The long-form human-readable description of this exploit Metasploit Module.
  #
  #   @return [String]

  # @!attribute name
  #   The human-readable name of this exploit Metasploit Module.  This can be thought of as the title or summary of
  #   the Metasploit Module.
  #
  #   @return [String]

  # @!attribute nop_class_id
  #   The foreign key for the {#nop_class} association.
  #
  #   @return [Integer]

  #
  # Validations
  #

  validates :description,
            presence: true
  validates :name,
            presence: true
  validates :nop_class,
            presence: true
  validates :nop_class_id,
            uniqueness: true

  Metasploit::Concern.run(self)
end