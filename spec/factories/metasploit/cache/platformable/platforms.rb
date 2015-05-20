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

  #
  # Traits
  #

  trait :metasploit_cache_platformable_platform do
    platform { generate :metasploit_cache_platform }
  end
end