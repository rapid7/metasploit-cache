# Define constants for {Metasploit::Cache::Payload::Ancestor#payload_type}.
module Metasploit::Cache::Payload::Ancestor::Type
  #
  # CONSTANTS
  #

  # Single payloads that are a Ruby `Class`
  SINGLE = 'single'
  # Stage payloads that are a Ruby `Module` that must be downloaded by a {STAGER} payload.
  STAGE = 'stage'
  # Stager payloads that are a Ruby `Module` that is small and downloads the larger {STAGE} payload.
  STAGER = 'stager'

  # Array<String> of all supported
  # {Metasploit::Cache::Payload::Ancestor#payload_type Metasploit Module ancestor payload types}
  ALL = [
      SINGLE,
      STAGE,
      STAGER
  ]
end