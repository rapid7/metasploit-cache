FactoryGirl.define do
  #
  # Factories
  #

  factory :metasploit_cache_auxiliary_reference,
          class: Metasploit::Cache::Referencable::Reference,
          traits: [:metasploit_cache_referencable_reference] do
    association :referencable, factory: :metasploit_cache_auxiliary_instance
  end

  factory :metasploit_cache_encoder_reference,
          class: Metasploit::Cache::Referencable::Reference,
          traits: [:metasploit_cache_referencable_reference] do
    association :referencable, factory: :metasploit_cache_encoder_instance
  end

  factory :metasploit_cache_exploit_reference,
          class: Metasploit::Cache::Referencable::Reference,
          traits: [:metasploit_cache_referencable_reference] do
    association :referencable, factory: :metasploit_cache_exploit_instance
  end

  factory :metasploit_cache_nop_reference,
          class: Metasploit::Cache::Referencable::Reference,
          traits: [:metasploit_cache_referencable_reference] do
    association :referencable, factory: :metasploit_cache_nop_instance
  end

  factory :metasploit_cache_payload_single_reference,
          class: Metasploit::Cache::Referencable::Reference,
          traits: [:metasploit_cache_referencable_reference] do
    association :referencable, factory: :metasploit_cache_payload_single_instance
  end

  factory :metasploit_cache_payload_stage_reference,
          class: Metasploit::Cache::Referencable::Reference,
          traits: [:metasploit_cache_referencable_reference] do
    association :referencable, factory: :metasploit_cache_payload_stage_instance
  end

  factory :metasploit_cache_payload_stager_reference,
          class: Metasploit::Cache::Referencable::Reference,
          traits: [:metasploit_cache_referencable_reference] do
    association :referencable, factory: :metasploit_cache_payload_stager_instance
  end

  factory :metasploit_cache_payload_post_reference,
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