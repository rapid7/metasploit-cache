FactoryGirl.define do
  #
  # Factories
  #

  factory :metasploit_cache_auxiliary_instance,
          class: Metasploit::Cache::Auxiliary::Instance do
    transient do
      action_count 1
      licenses_count 1
    end

    description { generate :metasploit_cache_auxiliary_instance_description }
    name { generate :metasploit_cache_auxiliary_instance_name }
    stance { generate :metasploit_cache_module_stance }

    #
    # Associations
    #

    association :auxiliary_class, factory: :metasploit_cache_auxiliary_class

    #
    # Callbacks
    #

    # Create associated objects w/ the counts established above in the
    # transient attributes. This enables specs using these factories to
    # specify a number of associated objects and therefore easily make valid/invalid
    # instances.
    after(:build) { |auxiliary_instance, evaluator|
      auxiliary_instance.actions = build_list(
          :metasploit_cache_auxiliary_action,
          evaluator.action_count,
          actionable: auxiliary_instance
      )
      auxiliary_instance.licensable_licenses = build_list(
          :metasploit_cache_auxiliary_license,
          evaluator.licenses_count,
          licensable: auxiliary_instance
      )
    }
  end

  #
  # Sequences
  #

  sequence :metasploit_cache_auxiliary_instance_description do |n|
    "Metasploit::Cache::Auxiliary::Instance#description #{n}"
  end

  sequence :metasploit_cache_auxiliary_instance_name do |n|
    "Metasploit::Cache::Auxiliary::Instance#name #{n}"
  end
end