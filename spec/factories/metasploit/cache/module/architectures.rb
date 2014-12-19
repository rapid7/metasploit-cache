FactoryGirl.define do
  module_architectures_module_types = Metasploit::Cache::Module::Instance.module_types_that_allow(:module_architectures)
  targets_module_types = Metasploit::Cache::Module::Instance.module_types_that_allow(:targets)

  # have to remove target supporting types so that target architectures won't interfere with module architectures
  metasploit_cache_module_architecture_module_types = module_architectures_module_types - targets_module_types

  sequence :metasploit_cache_module_architecture_module_type, metasploit_cache_module_architecture_module_types.cycle

  trait :metasploit_cache_module_architecture do
    ignore do
      module_type { generate :metasploit_cache_module_architecture_module_type }
    end
  end
end