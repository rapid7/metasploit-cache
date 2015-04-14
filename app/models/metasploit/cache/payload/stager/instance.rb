# Instance-level metadata for stager payload Metasploit Module
class Metasploit::Cache::Payload::Stager::Instance < ActiveRecord::Base
  #
  # Attributes
  #

  # @!attribute description
  #   The long-form human-readable description of this stager payload Metasploit Module.
  #
  #   @return [String]

  # @!attribute handler_type_alias
  #   Alternate name for the handler_type to prevent naming collisions in staged payload Metasploit Modules that use
  #   this stager payload Metasploit Module.
  #
  #   @return [String]

  # @!attribute name
  #   The human-readable name of this stager payload Metasploit Module.  This can be thought of as the title or summary
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
  #   @param description [String] The long-form human-readable description of this stager payload Metasploit Module.
  #   @return [void]

  # @!attribute handler_type_alias=(handler_type_alias)
  #   Sets {#handler_type_alias}.
  #
  #   @param handler_type_alias [String, nil] Alternate name for the handler_type to prevent naming collisions in staged
  #     payload Metasploit Modules that use this stager payload Metasploit Module.
  #   @return [void]

  # @!method name=(name)
  #   Sets {#name}.
  #
  #   @param name [String] The human-readable name of this stager payload Metasploit Module.  This can be thought of as
  #     the title or summary of the Metasploit Module.
  #   @return [void]

  Metasploit::Concern.run(self)
end