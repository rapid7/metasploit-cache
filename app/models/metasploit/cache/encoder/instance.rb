# Instance-level metadata for an encoder  Metasploit Module.
class Metasploit::Cache::Encoder::Instance < ActiveRecord::Base
  #
  # Associations
  #

  # The class-level metadata for this instance metadata.
  #
  # @return [Metasploit::Cache::Encoder::Class]
  belongs_to :encoder_class,
             class_name: 'Metasploit::Cache::Encoder::Class',
             inverse_of: :encoder_instance

  # The {Metasploit::Cache::License} objects that are associated with this instance
  #
  # @return[ActiveRecord::Relation<Metasploit::Cache::Licensable::License>]
  has_many :licensable_licenses,
           as: :licensable,
           class_name: 'Metasploit::Cache::Licensable::License'

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

  #
  # Instance Methods
  #

  # @!method description=(description)
  #   Sets {#description}.
  #
  #   @param description [String] The long-form human-readable description of this encoder Metasploit Module.
  #   @return [void]

  # @!method name=(name)
  #   Sets {#name}.
  #
  #   @param name [String] The human-readable name of this encoder Metasploit Module.  This can be thought of as the
  #     title or summary of the Metasploit Module.
  #   @return [void]

  Metasploit::Concern.run(self)
end