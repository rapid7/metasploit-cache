FactoryGirl.define do


  factory :metasploit_cache_auxiliary_action,
          class: Metasploit::Cache::Actionable::Action do
    association :actionable, factory: :metasploit_cache_auxiliary_instance
  end

  factory :metasploit_cache_post_post,
          class: Metasploit::Cache::Actionable::Action do
    association :actionable, factory: :metasploit_cache_post_instance
  end

  trait :metasploit_cache_actionable_action do
    name { generate :metasploit_cache_actionable_action }
  end
end