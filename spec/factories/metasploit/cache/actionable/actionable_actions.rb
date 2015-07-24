FactoryGirl.define do
  trait :metasploit_cache_actionable_actions do
    transient do
      action_count 1
    end

    after(:build) do |actionable, evaluator|
      actionable.actions = build_list(
          :metasploit_cache_actionable_action,
          evaluator.action_count,
          actionable: actionable
      )
    end
  end
end