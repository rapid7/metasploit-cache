FactoryGirl.define do
  total_architectures = Metasploit::Cache::Architecture::ABBREVIATIONS.length
  total_platforms = Metasploit::Cache::Platform.fully_qualified_name_set.length

  factory :metasploit_cache_module_target,
          :class => Metasploit::Cache::Module::Target do
    transient do
      # have to use module_type from metasploit_cache_model_module_target_module_type trait to ensure module_instance
      # will support module targets.
      module_class { FactoryGirl.create(:metasploit_cache_module_class, module_type: module_type) }

      module_type { generate :metasploit_cache_module_target_module_type }

      target_architectures_length { Random.rand(1 .. total_architectures) }
      target_platforms_length { Random.rand(1 .. total_platforms) }
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
      [:architecture, :platform].each do |infix|
        attribute = "target_#{infix.to_s.pluralize}"
        factory = "metasploit_cache_module_target_#{infix}"
        length = evaluator.send("#{attribute}_length")

        # factories add selves to associations on metasploit_cache_module_target
        FactoryGirl.build_list(
            factory,
            length,
            module_target: metasploit_cache_module_target
        )
      end

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