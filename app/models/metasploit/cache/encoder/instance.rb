# Instance-level metadata for an encoder  Metasploit Module.
class Metasploit::Cache::Encoder::Instance < ActiveRecord::Base
  #
  #
  # Associations
  #
  #

  # The class-level metadata for this instance metadata.
  #
  # @return [Metasploit::Cache::Encoder::Class]
  belongs_to :encoder_class,
             class_name: 'Metasploit::Cache::Encoder::Class',
             inverse_of: :encoder_instance

  # Joins {#licenses} to this encoder Metasploit Module.
  has_many :licensable_licenses,
           as: :licensable,
           class_name: 'Metasploit::Cache::Licensable::License'

  #
  # through: :licensable_licenses
  #

  # The {Metasploit::Cache::License} for the code in this encoder Metasploit Module.
  has_many :licenses,
           class_name: 'Metasploit::Cache::License',
           through: :licensable_licenses

  #
  # Attributes
  #

  # @!attribute description
  # The long-form human-readable description of this auxiliary Metasploit Module.
  #
  #   @return [String]

  # @!attribute name
  #   The human-readable name of this encoder Metasploit Module.  This can be thought of as the title or summary of
  #   the Metasploit Module.
  #
  #   @return [String]

  #
  # Validations
  #

  validates :description,
            presence: true

  validates :encoder_class,
            presence: true

  validates :licensable_licenses,
            length: {
              minimum: 1
            }

  validates :name,
            presence: true

  Metasploit::Concern.run(self)
end