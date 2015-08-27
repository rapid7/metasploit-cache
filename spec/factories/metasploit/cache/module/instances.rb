FactoryGirl.define do
  factory_by_attribute = {
      module_references: :metasploit_cache_module_reference
  }
  total_platforms = Metasploit::Cache::Platform.fully_qualified_name_set.length
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
      # this length is only used if supports?(:module_platforms) is true.  It can be set to 0 when
      # supports?(:module_platforms) is true to make the after(:build) skip building the module platforms automatically.
      module_platforms_length {
        Random.rand(minimum_with_elements .. total_platforms)
      }

      module_references_length(&arbitrary_supported_length)
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
            factory_by_attribute.each do |attribute, factory|
              if metasploit_cache_module_instance.allows?(attribute)
                length = evaluator.send("#{attribute}_length")

                collection = length.times.collect {
                  FactoryGirl.build(factory, module_instance: metasploit_cache_module_instance)
                }

                metasploit_cache_module_instance.send("#{attribute}=", collection)
              end
            end

            # make sure targets are generated first so that module_platforms can be include the targets' platforms.
            if metasploit_cache_module_instance.allows?(:targets)
              # factory adds built module_targets to module_instance.
              FactoryGirl.build_list(
                  :metasploit_cache_module_target,
                  evaluator.targets_length,
                  module_instance: metasploit_cache_module_instance
              )
              # module_platforms will be derived from targets
            else
              # if there are no targets, then platforms need to be explicitly defined on module instance since they
              # can't be derived from anything
              if metasploit_cache_module_instance.allows?(:module_platforms)
                metasploit_cache_module_instance.module_platforms = FactoryGirl.build_list(
                    :metasploit_cache_module_platform,
                    evaluator.module_platforms_length,
                    module_instance: metasploit_cache_module_instance
                )
              end
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
