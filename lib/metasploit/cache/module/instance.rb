# Abstract namespace for functionality shared between all `Metasploit::Cache::<module_type>::Instance` classes:
# * {Metasploit::Cache::Auxiliary::Instance}
# * {Metasploit::Cache::Exploit::Instance}
# * {Metasploit::Cache::Encoder::Instance}
# * {Metasploit::Cache::Nop::Instance}
# * {Metasploit::Cache::Payload::Single::Instance}
# * {Metasploit::Cache::Payload::Stage::Instance}
# * {Metasploit::Cache::Payload::Staged::Instance}
# * {Metasploit::Cache::Payload::Stager::Instance}
# * {Metasploit::Cache::Post::Instance}
module Metasploit::Cache::Module::Instance
  extend ActiveSupport::Autoload

  autoload :Load
end