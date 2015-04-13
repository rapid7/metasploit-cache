# Namespace for stage payload Metasploit Module cache metadata, including
# {Metasploit::Cache::Payload::Stage::Ancestor ancestors}, {Metasploit::Cache::Payload::Stage::Class classes}, and
# {Metasploit::Cache::Paylaod::Stage::Instance instances}.
module Metasploit::Cache::Payload::Stage
  extend ActiveSupport::Autoload

  autoload :Ancestor
  autoload :Class
  autoload :Instance
end