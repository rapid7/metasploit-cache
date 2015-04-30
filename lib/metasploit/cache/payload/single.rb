# Namespace for single payload Metasploit Module cache metadata, including
# {Metasploit::Cache::Payload::Single::Ancestor ancestors} and {Metasploit::Cache::Payload::Single::Class classes}.
module Metasploit::Cache::Payload::Single
  extend ActiveSupport::Autoload

  autoload :Ancestor
  autoload :Class
end