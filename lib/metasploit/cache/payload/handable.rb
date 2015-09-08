# Namespace for payloads ({Metasploit::Cache::Payload::Single::Unhandled::Instance} and
# {Metasploit::Cache::Payload::Stager::Instance}) that have a `#handler`.
module Metasploit::Cache::Payload::Handable
  extend ActiveSupport::Autoload

  autoload :Ephemeral
end