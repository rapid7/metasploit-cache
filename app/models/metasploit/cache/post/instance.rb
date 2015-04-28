# Instance-level metadata for a post Metasploit Module.
class Metasploit::Cache::Post::Instance < ActiveRecord::Base
  #
  # Attributes
  #

  # @!attribute description
  #   The long-form human-readable description of this post Metasploit Module.
  #
  #   @return [String]

  # @!attribute disclosed_on
  #   The public disclosure date of the exploit exercised by this post Metasploit Module.
  #
  #   @return [Date]

  #
  # Validations
  #

  validates :description,
            presence: true
  validates :disclosed_on,
            presence: true
  validates :name,
            presence: true

  #
  # Instance Methods
  #

  # @!method description=(description)
  #   Sets {#description}.
  #
  #   @param description [String] The long-form human-readable description of this post Metasploit Module.
  #   @return [void]

  # @!method disclosed_on=(disclosed_on)
  #   Sets {#disclosed_on}.
  #
  #   @param disclosed_on [Date] The date the exploit exercised by this post Metasploit Module was disclosed to the
  #     public.
  #   @return [void]

  Metasploit::Concern.run(self)
end