# Instance-level metadata for stage payload Metasploit Module
class Metasploit::Cache::Payload::Stage::Instance < ActiveRecord::Base
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

  #
  # Validations
  #

  validates :description,
            presence: true
  validates :name,
            presence: true

  #
  # Instance Methods
  #

  # @!method description=(description)
  #   Sets {#description}.
  #
  #   @param description [String] The long-form human-readable description of this stage payload Metasploit Module.
  #   @return [void]

  # @!method name=(name)
  #   Sets {#name}.
  #
  #   @param name [String] The human-readable name of this stage payload Metasploit Module.  This can be thought of as
  #     the title or summary of the Metasploit Module.
  #   @return [void]

  Metasploit::Concern.run(self)
end