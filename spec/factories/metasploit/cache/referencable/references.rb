FactoryGirl.define do
  #
  # Factories
  #

  factory :metasploit_cache_auxiliary_reference,
          class: Metasploit::Cache::Referencable::Reference,
          traits: [:metasploit_cache_referencable_reference] do
    association :referencable, factory: :metasploit_cache_auxiliary_instance
  end


  factory :metasploit_cache_exploit_reference,
          class: Metasploit::Cache::Referencable::Reference,
          traits: [:metasploit_cache_referencable_reference] do
    association :referencable, factory: :metasploit_cache_exploit_instance
  end


  factory :metasploit_cache_post_reference,
          class: Metasploit::Cache::Referencable::Reference,
          traits: [:metasploit_cache_referencable_reference] do
    association :referencable, factory: :metasploit_cache_payload_post_instance
  end

  #
  # Traits
  #

  trait :metasploit_cache_referencable_reference do
    association :reference, factory: :metasploit_cache_reference
  end
end