FactoryGirl.define do
  # chosen so that there is at least 1 element even if 0 is allowed so that factories always test that the associated
  # records are handled.
  minimum_with_elements = 1
  # arbitrarily chosen maximum when there are a bounded total of the associated records.  Most chosen because 3 will
  # test that there is no 1 or 2 special casing make it work.
  arbitrary_maximum = 3
  arbitrary_supported_length = ->{
    Random.rand(minimum_with_elements .. arbitrary_maximum)
  }

  factory :metasploit_cache_module_instance,
          class: Metasploit::Cache::Module::Instance do
    transient do
      targets_length(&arbitrary_supported_length)

      #
      # Callback helpers
      #

      # Can't use the after(:build) system because the associations need to be set before writing the template

      before_write_template {
        ->(metasploit_cache_module_instance, evaluator){
          module_class = metasploit_cache_module_instance.module_class

          # only attempt to build supported associations if the module_class is valid because supports depends on a valid
          # module_type and validating the module_class will derive module_type.
          if module_class && module_class.valid?
            if metasploit_cache_module_instance.allows?(:targets)
              # factory adds built module_targets to module_instance.
              FactoryGirl.build_list(
                  :metasploit_cache_module_target,
                  evaluator.targets_length,
                  module_instance: metasploit_cache_module_instance
              )
            end
          end
        }
      }

      write_template {
        ->(module_instance, _evaluator) {
          Metasploit::Cache::Module::Instance::Spec::Template.write(module_instance: module_instance)
        }
      }
    end

    #
    # Associations
    #

    association :module_class, factory: :metasploit_cache_module_class

    #
    # Attributes
    #

    description { generate :metasploit_cache_module_instance_description }
    disclosed_on { generate :metasploit_cache_module_instance_disclosed_on }
    license { generate :metasploit_cache_module_instance_license }
    name { generate :metasploit_cache_module_instance_name }
    privileged { generate :metasploit_cache_module_instance_privileged }

    # must be explicit and not part of trait to ensure it is run after module_class is created.
    stance {
      if stanced?
        generate :metasploit_cache_module_stance
      else
        nil
      end
    }

    #
    # Callbacks
    #

    after(:build) do |module_instance, evaluator|
      instance_exec(module_instance, evaluator, &evaluator.before_write_template)
      instance_exec(module_instance, evaluator, &evaluator.write_template)
    end
  end

  sequence :metasploit_cache_module_instance_description do |n|
    "Module Description #{n}"
  end

  sequence :metasploit_cache_module_instance_disclosed_on do |n|
    Date.today - n
  end

  sequence :metasploit_cache_module_instance_license do |n|
    "Module License #{n}"
  end

  sequence :metasploit_cache_module_instance_name do |n|
    "Module Name #{n}"
  end

  sequence :metasploit_cache_module_instance_privileged, Metasploit::Cache::Module::Instance::PRIVILEGES.cycle
end
