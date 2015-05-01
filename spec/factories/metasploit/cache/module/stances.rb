FactoryGirl.define do
  sequence :metasploit_cache_module_stance,
           Metasploit::Cache::Spec.sample_stream(Metasploit::Cache::Module::Stance::ALL)
end
