FactoryGirl.define do
  factory :metasploit_cache_auxiliary_instance,
          class: Metasploit::Cache::Auxiliary::Instance do
    transient do
      actions_count 1
    end

    #
    # Associations
    #

    association :auxiliary_class, factory: :metasploit_cache_auxiliary_class

    #
    # Callbacks
    #

    after(:build) { |auxiliary_instance, evaluator|
      auxiliary_instance.actions = build_list(
          :metasploit_cache_auxiliary_action,
          evaluator.actions_count,
          actionable: auxiliary_instance
      )
    }
  end
end