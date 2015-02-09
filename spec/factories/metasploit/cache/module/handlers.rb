FactoryGirl.define do
  sequence :metasploit_cache_module_handler_type, Metasploit::Cache::Module::Handler::TYPES.cycle
end