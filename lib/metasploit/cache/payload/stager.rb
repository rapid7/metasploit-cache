# Namespace for stager payload Metasploit Module cache metadata, including
# {Metasploit::Cache::Payload::Stager::Ancestor ancestors}.
module Metasploit::Cache::Payload::Stager
  extend ActiveSupport::Autoload

  autoload :Ancestor
  autoload :Class
end