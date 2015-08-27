# Abstract namespace for functionality shared between all `Metasploit::Cache::<module_type>` classes:
# * {Metasploit::Cache::Auxiliary}
# * {Metasploit::Cache::Exploit}
# * {Metasploit::Cache::Encoder}
# * {Metasploit::Cache::Nop}
# * {Metasploit::Cache::Payload::Stage}
# * {Metasploit::Cache::Payload::Staged}
# * {Metasploit::Cache::Payload::Stager}
# * {Metasploit::Cache::Post}
module Metasploit::Cache::Module
  extend ActiveSupport::Autoload

  autoload :Instance
end