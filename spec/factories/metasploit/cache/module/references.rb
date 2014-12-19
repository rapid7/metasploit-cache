FactoryGirl.define do
  module_references_module_types = Metasploit::Cache::Module::Instance.module_types_that_allow(:module_references)

  sequence :metasploit_cache_module_reference_module_type, module_references_module_types.cycle

  trait :metasploit_cache_module_reference do
    transient do
      module_type { generate :metasploit_cache_module_reference_module_type }
    end
  end
end