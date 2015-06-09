FactoryGirl.define do
  #
  # Factories
  #

  factory :metasploit_cache_auxiliary_contribution,
          class: Metasploit::Cache::Contribution,
          traits: [
              :metasploit_cache_contribution
          ] do
    association :contributable, factory: :metasploit_cache_auxiliary_instance
  end

  factory :metasploit_cache_encoder_contribution,
          class: Metasploit::Cache::Contribution,
          traits: [
              :metasploit_cache_contribution
          ] do
    association :contributable, factory: :metasploit_cache_encoder_instance
  end

  factory :metasploit_cache_exploit_contribution,
          class: Metasploit::Cache::Contribution,
          traits: [
              :metasploit_cache_contribution
          ] do
    association :contributable, factory: :metasploit_cache_exploit_instance
  end

  factory :metasploit_cache_nop_contribution,
          class: Metasploit::Cache::Contribution,
          traits: [
              :metasploit_cache_contribution
          ] do
    association :contributable, factory: :metasploit_cache_nop_instance
  end

  factory :metasploit_cache_payload_single_contribution,
          class: Metasploit::Cache::Contribution,
          traits: [
              :metasploit_cache_contribution
          ] do
    association :contributable, factory: :metasploit_cache_payload_single_instance
  end

  factory :metasploit_cache_payload_stage_contribution,
          class: Metasploit::Cache::Contribution,
          traits: [
              :metasploit_cache_contribution
          ] do
    association :contributable, factory: :metasploit_cache_payload_stage_instance
  end

  factory :metasploit_cache_payload_stager_contribution,
          class: Metasploit::Cache::Contribution,
          traits: [
              :metasploit_cache_contribution
          ] do
    association :contributable, factory: :metasploit_cache_payload_stager_instance
  end

  factory :metasploit_cache_post_contribution,
          class: Metasploit::Cache::Contribution,
          traits: [
              :metasploit_cache_contribution
          ] do
    association :contributable, factory: :metasploit_cache_post_instance
  end

  #
  # Traits
  #

  trait :metasploit_cache_contribution do
    association :author, factory: :metasploit_cache_author
  end

  trait :metasploit_cache_contribution_email_address do
    association :email_address, factory: :metasploit_cache_email_address
  end
end