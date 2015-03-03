FactoryGirl.define do
  factory :metasploit_cache_module_class,
          class: Metasploit::Cache::Module::Class do
    # Don't set full_name: before_validation will derive it from {Metasploit::Cache::Module::Class#module_type} and
    # {Metasploit::Cache::Module::Class::reference_name}.

    transient do
      # derives from associations in instance, so don't set on instance
      module_type { generate :metasploit_cache_module_type }

      # depends on module_type
      # ignored because model attribute will derived from reference_name, this factory attribute is used to generate
      # the correct reference_name.
      payload_type {
        # module_type is factory attribute, not model attribute
        if module_type == Metasploit::Cache::Module::Type::PAYLOAD
          generate :metasploit_cache_module_class_payload_type
        end
      }

      #
      # Callback helpers
      #

      before_write_template {
        ->(module_class, evaluator) {}
      }
      write_template {
        ->(module_class, evaluator) {
          Metasploit::Cache::Module::Class::Spec::Template.write(module_class: module_class)
        }
      }
    end

    #
    # Associations
    #

    # depends on module_type and payload_type
    ancestors {
      ancestors  = []

      # ignored attribute from factory; NOT the instance attribute
      case module_type
      when 'payload'
        # ignored attribute from factory; NOT the instance attribute
        case payload_type
        when 'single'
          ancestors << FactoryGirl.create(:single_metasploit_cache_payload_ancestor)
        else
          raise ArgumentError,
                "Don't know how to create Metasploit::Cache::Module::Class#ancestors " \
                    "for Metasploit::Cache::Module::Class#payload_type (#{payload_type})"
        end
      else
        ancestors << FactoryGirl.create(:metasploit_cache_module_ancestor, :module_type => module_type)
      end

      ancestors
    }

    rank { generate :metasploit_cache_module_rank }

    #
    # Callbacks
    #

    after(:build) do |module_class, evaluator|
      instance_exec(evaluator, evaluator, &evaluator.before_write_template)
      instance_exec(evaluator, evaluator, &evaluator.write_template)
    end
  end

  sequence :metasploit_cache_module_class_payload_type, Metasploit::Cache::Module::Class::PAYLOAD_TYPES.cycle
end