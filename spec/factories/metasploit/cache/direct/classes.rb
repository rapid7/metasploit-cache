FactoryGirl.define do
  #
  # Sequences
  #

  sequence :metasploit_cache_direct_class_factory,
           Metasploit::Cache::Direct::Class::Spec.random_factory

  #
  # Traits
  #

  trait :metasploit_cache_direct_class do
    transient do
      #
      # Callback helpers
      #

      before_write_template {
        ->(direct_class, evaluator) {}
      }
      write_template {
        ->(direct_class, evaluator) {
          Metasploit::Cache::Direct::Class::Spec::Template.write(direct_class: direct_class)
        }
      }
    end

    #
    # Associations
    #

    rank { generate :metasploit_cache_module_rank }

    #
    # Callbacks
    #

    after(:build) do |direct_class, evaluator|
      instance_exec(evaluator, evaluator, &evaluator.before_write_template)
      instance_exec(evaluator, evaluator, &evaluator.write_template)
    end
  end
end