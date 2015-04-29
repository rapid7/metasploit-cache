# Handles the local connection for a {Metasploit::Cache::Payload::Single::Instance single payload Metasploit Module} or
# {Metasploit::Cache::Payload::Stager::Instance stager payload Metasploit Module}.
class Metasploit::Cache::Payload::Handler < ActiveRecord::Base
  extend ActiveSupport::Autoload

  autoload :GeneralType

  #
  # Attributes
  #

  # @!attribute general_handler_type
  #   The {Metasploit::Cache::Payload::Handler::GeneralType general handler type}.
  #
  #   @return [String]

  # @!attribute handler_type
  #   The type of this handler.  Normally, in metasploit-framework, this is a Module method, `handler_type` that returns
  #   the underscored relative `Module#name`.
  #
  #   @return [String]

  #
  # Validations
  #

  validates :general_handler_type,
            inclusion: {
                in: Metasploit::Cache::Payload::Handler::GeneralType::ALL
            }
  validates :handler_type,
            presence: true,
            uniqueness: true

  #
  # Instance Methods
  #

  # @!method general_handler_type=(general_handler_type)
  #   Sets {#general_handler_type}.
  #
  #   @param general_handler_type [String] the general handler type
  #   @return [void]

  # @!method handler_type=(handler_type)
  #   Sets {#handler_type}.
  #
  #   @param handler_type [String] the specific handler type
  #   @return [void]

  Metasploit::Concern.run(self)
end