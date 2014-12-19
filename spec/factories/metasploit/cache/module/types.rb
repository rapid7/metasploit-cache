FactoryGirl.define do
  sequence :metasploit_cache_module_type, Metasploit::Cache::Module::Type::ALL.cycle

  sequence :metasploit_cache_non_payload_module_type, Metasploit::Cache::Module::Type::NON_PAYLOAD.cycle
end