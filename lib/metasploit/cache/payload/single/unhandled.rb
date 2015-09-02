# Namespace for single payload Metasploit Module class that does not have the handler mixed in.
module Metasploit::Cache::Payload::Single::Unhandled
  extend ActiveSupport::Autoload

  autoload :Class
end