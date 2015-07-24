FactoryGirl.define do
  trait :metasploit_cache_architecturable_architecturable_architectures do
    transient do
      architecturable_architecture_count 1
    end

    after(:build) do |architecturable, evaluator|
      architecturable.architecturable_architectures = build_list(
          :metasploit_cache_architecturable_architecture,
          evaluator.architecturable_architecture_count,
          architecturable: architecturable
      )
    end
  end
end