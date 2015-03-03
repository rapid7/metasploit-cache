# Namespace for payload Metasploit Module cache metadata.  Payloads are further broken up by payload type:
# * {Metasploit::Cache::Payload::Single single}
module Metasploit::Cache::Payload
  extend ActiveSupport::Autoload

  autoload :Ancestor
  autoload :Single
end