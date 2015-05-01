# Namespace for stage payload Metasploit Module cache metadata, including
# {Metasploit::Cache::Payload::Stage::Ancestor ancestors} and {Metasploit::Cache::Payload::Stage::Class classes}.
module Metasploit::Cache::Payload::Stage
  extend ActiveSupport::Autoload

  autoload :Ancestor
  autoload :Class
end