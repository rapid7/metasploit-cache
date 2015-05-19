FactoryGirl.define do
  #
  # Factories
  #

  factory :metasploit_cache_encoder_architecture,
          class: Metasploit::Cache::Architecturable::Architecture,
          traits: [
              :metasploit_cache_architecturable_architecture
          ] do
    association :architecturable, factory: :metasploit_cache_encoder_instance
  end

  factory :metasploit_cache_exploit_target_architecture,
          class: Metasploit::Cache::Architecturable::Architecture,
          traits: [
              :metasploit_cache_architecturable_architecture
          ] do
    association :architecturable, factory: :metasploit_cache_exploit_target
  end

  factory :metasploit_cache_nop_architecture,
          class: Metasploit::Cache::Architecturable::Architecture,
          traits: [
              :metasploit_cache_architecturable_architecture
          ] do
    association :architecturable, factory: :metasploit_cache_nop_instance
  end

  #
  # Traits
  #

  trait :metasploit_cache_architecturable_architecture do
    architecture { generate :metasploit_cache_architecture }
  end
end