FactoryGirl.define do
  #
  # Factories
  #

  factory :metasploit_cache_auxiliary_action,
          class: Metasploit::Cache::Actionable::Action,
          traits: [:metasploit_cache_actionable_action] do
    association :actionable, factory: :metasploit_cache_auxiliary_instance
  end

  factory :metasploit_cache_post_post,
          class: Metasploit::Cache::Actionable::Action,
          traits: [:metasploit_cache_actionable_action] do
    association :actionable, factory: :metasploit_cache_post_instance
  end

  #
  # Sequences
  #

  sequence :metasploit_cache_actionable_action_name do |n|
    "Metasploit::Cache::Actionable::Action#name #{n}"
  end

  #
  # Traits
  #

  trait :metasploit_cache_actionable_action do
    name { generate :metasploit_cache_actionable_action_name }
  end
end