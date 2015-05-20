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

  #
  # Traits
  #

  trait :metasploit_cache_platformable_platform do
    platform { generate :metasploit_cache_platform }
  end
end