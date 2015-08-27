FactoryGirl.define do
  factory :metasploit_cache_module_target,
          :class => Metasploit::Cache::Module::Target do
    transient do
      # have to use module_type from metasploit_cache_model_module_target_module_type trait to ensure module_instance
      # will support module targets.
      module_class { FactoryGirl.create(:metasploit_cache_module_class, module_type: module_type) }

      module_type { generate :metasploit_cache_module_target_module_type }
    end

    #
    # Associations
    #

    module_instance {
      # module_instance MUST be built because it will fail validation without targets
      FactoryGirl.build(
          :metasploit_cache_module_instance,
          module_class: module_class,
          # disable module_instance factory's after(:build) from building module_targets since this factory is already
          # building it and if they both build module_targets, then the validations will detect a mismatch.
          targets_length: 0
      )
    }

    #
    # Attributes
    #

    index { module_instance.targets.length }
    name { generate :metasploit_cache_module_target_name }

    #
    # Callbacks
    #

    after(:build) { |metasploit_cache_module_target, evaluator|
      module_instance = metasploit_cache_module_target.module_instance

      unless module_instance.targets.include? metasploit_cache_module_target
        module_instance.targets << metasploit_cache_module_target
      end
    }
  end

  targets_module_types = Metasploit::Cache::Module::Instance.module_types_that_allow(:targets)

  sequence :metasploit_cache_module_target_module_type, targets_module_types.cycle

  sequence :metasploit_cache_module_target_name do |n|
    "Metasploit::Cache::Module::Target#name #{n}"
  end
end