# Helps with synchronizing Metasploit Handler Class with {Metasploit::Cache::Payload::Handler}
module Metasploit::Cache::Payload::Handler::Persister
  #
  # CONSTANTS
  #

  # Names of attributes on a Metasploit Handler Class and {Metasploit::Cache::Payload::Handler} that are synchronized.
  ATTRIBUTE_NAMES = [
      :general_handler_type,
      :handler_type,
      :name
  ].freeze

  #
  # Module Methods
  #

  # Converts attributes of `source` to Hash
  #
  # @param source [#general_handler_type, #handler_type]
  # @return [{general_handler_type: String, handler_type: String}]
  def self.attributes(source)
    ATTRIBUTE_NAMES.each_with_object({}) { |attribute_name, hash|
      hash[attribute_name] = source.public_send(attribute_name)
    }
  end
end