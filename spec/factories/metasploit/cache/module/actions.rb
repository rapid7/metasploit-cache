FactoryGirl.define do
  sequence :metasploit_cache_module_action_name do |n|
    "Metasploit::Cache::Module::Action#name #{n}"
  end

  trait :metasploit_cache_module_action do
    name { generate :metasploit_cache_module_action_name }
  end
end