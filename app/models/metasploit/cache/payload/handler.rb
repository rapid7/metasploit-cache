# Handles the local connection for a {Metasploit::Cache::Payload::Single::Instance single payload Metasploit Module} or
# {Metasploit::Cache::Payload::Stager::Instance stager payload Metasploit Module}.
class Metasploit::Cache::Payload::Handler < ActiveRecord::Base
  extend ActiveSupport::Autoload

  autoload :GeneralType

  #
  # Attributes
  #

  # @!attribute handler_type
  #   The type of this handler.  Normally, in metasploit-framework, this is a Module method, `handler_type` that returns
  #   the underscored relative `Module#name`.
  #
  #   @return [String]

  #
  # Validations
  #

  validates :handler_type,
            presence: true,
            uniqueness: true

  #
  # Instance Methods
  #

  # @!method handler_type=(handler_type)
  #   Sets {#handler_type}.
  #
  #   @param handler_type [String] the specific handler type
  #   @return [void]

  Metasploit::Concern.run(self)
end