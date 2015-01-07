FactoryGirl.define do
    factory :metasploit_cache_module_architecture,
          class: Metasploit::Cache::Module::Architecture do
    transient do
      # have to use module_type from metasploit_model_module_architecture trait to ensure module_instance will support
      # module architectures.
      module_class { FactoryGirl.create(:metasploit_cache_module_class, module_type: module_type) }
      module_type { generate :metasploit_cache_module_architecture_module_type }
    end

    #
    # Associations
    #

    architecture { generate :metasploit_cache_architecture }
    module_instance {
      FactoryGirl.build(
          :metasploit_cache_module_instance,
          # disable module_instance factory from building module_architectures since this factory is already building
          # one
          module_architectures_length: 0,
          module_class: module_class
      )
    }

    #
    # Callbacks
    #

    after(:build) do |module_architecture|
      module_instance = module_architecture.module_instance

      if module_instance
        unless module_instance.module_architectures.include? module_architecture
          module_instance.module_architectures << module_architecture
        end
      end
    end
  end

  module_architectures_module_types = Metasploit::Cache::Module::Instance.module_types_that_allow(:module_architectures)
  targets_module_types = Metasploit::Cache::Module::Instance.module_types_that_allow(:targets)

  # have to remove target supporting types so that target architectures won't interfere with module architectures
  metasploit_cache_module_architecture_module_types = module_architectures_module_types - targets_module_types

  sequence :metasploit_cache_module_architecture_module_type, metasploit_cache_module_architecture_module_types.cycle
end