FactoryGirl.define do
  #
  # Factories
  #

  factory :metasploit_cache_encoder_platform,
          class: Metasploit::Cache::Platformable::Platform,
          traits: [
              :metasploit_cache_platformable_platform
          ] do
    association :platformable, factory: :metasploit_cache_encoder_instance
  end

  factory :metasploit_cache_exploit_target_platform,
          class: Metasploit::Cache::Platformable::Platform,
          traits: [
              :metasploit_cache_platformable_platform
          ] do
    association :platformable, factory: :metasploit_cache_exploit_target
  end

  factory :metasploit_cache_nop_platform,
          class: Metasploit::Cache::Platformable::Platform,
          traits: [
              :metasploit_cache_platformable_platform
          ] do
    association :platformable, factory: :metasploit_cache_nop_instance
  end

  factory :metasploit_cache_payload_single_platform,
          class: Metasploit::Cache::Platformable::Platform,
          traits: [
              :metasploit_cache_platformable_platform
          ] do
    association :platformable, factory: :metasploit_cache_payload_single_instance
  end

  factory :metasploit_cache_payload_stage_platform,
          class: Metasploit::Cache::Platformable::Platform,
          traits: [
              :metasploit_cache_platformable_platform
          ] do
    association :platformable, factory: :metasploit_cache_payload_stage_instance
  end

  #
  # Traits
  #

  trait :metasploit_cache_platformable_platform do
    platform { generate :metasploit_cache_platform }
  end
end