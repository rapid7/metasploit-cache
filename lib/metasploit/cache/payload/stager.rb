# Namespace for stager payload Metasploit Module cache metadata, including
# {Metasploit::Cache::Payload::Stager::Ancestor ancestors}, {Metasploit::Cache::Payload::Stager::Class classes}, and
# {Metasploit::Cache::Payload::Stager::Instance instances}.
module Metasploit::Cache::Payload::Stager
  extend ActiveSupport::Autoload

  autoload :Ancestor
  autoload :Class
  autoload :Instance
end