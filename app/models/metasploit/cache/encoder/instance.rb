# Instance-level metadata for an encoder  Metasploit Module.
class Metasploit::Cache::Encoder::Instance < ActiveRecord::Base
  #
  # Attributes
  #

  # @!attribute description
  # The long-form human-readable description of this auxiliary Metasploit Module.
  #
  #   @return [String]

  #
  # Validations
  #

  validates :description,
            presence: true

  #
  # Instance Methods
  #

  # @!method description=(description)
  #   Sets {#description}.
  #
  #   @param description [String] The long-form human-readable description of this encoder Metasploit Module.
  #   @return [void]

  Metasploit::Concern.run(self)
end