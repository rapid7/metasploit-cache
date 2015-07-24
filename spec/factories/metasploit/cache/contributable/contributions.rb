FactoryGirl.define do
  trait :metasploit_cache_contributable_contributions do
    transient do
      contribution_count 1
    end

    after(:build) do |contributable, evaluator|
      contributable.contributions = build_list(
          :metasploit_cache_contribution,
          evaluator.contribution_count,
          contributable: contributable
      )
    end
  end
end