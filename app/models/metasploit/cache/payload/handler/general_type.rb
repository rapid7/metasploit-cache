# Namespace for valid `Metasploit::Cache::Payload::Handler#general_type`s.
module Metasploit::Cache::Payload::Handler::GeneralType
  #
  # CONSTANTS
  #

  # Binds to a remote socket
  BIND = 'bind'

  # Find a pre-existing socket either directly or through some remote service
  FIND = 'find'

  # Payloads that have no handler because they have no connection
  NONE = 'none'

  # Connect back to a local socket
  REVERSE = 'reverse'

  # Connection is tunnelled through another protocol, such as HTTP(S).  All {TUNNEL} handlers are also {REVERSE}
  # currently.
  TUNNEL = 'tunnel'

  # All valid values for `Metasploit::Cache::Payload::Handler#general_type`.
  ALL = [
      BIND,
      FIND,
      NONE,
      REVERSE,
      TUNNEL
  ]
end