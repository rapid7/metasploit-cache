FactoryGirl.define do

  factory :metasploit_cache_auxiliary_license,
                 class: Metasploit::Cache::Licensable::License,
                 traits: [:metasploit_cache_licensable_license] do
    association :licensable, factory: :metasploit_cache_auxiliary_instance
  end

  factory :metasploit_cache_encoder_license,
          class: Metasploit::Cache::Licensable::License,
          traits: [:metasploit_cache_licensable_license] do
    association :licensable, factory: :metasploit_cache_encoder_instance
  end

  factory :metasploit_cache_exploit_license,
          class: Metasploit::Cache::Licensable::License,
          traits: [:metasploit_cache_licensable_license] do

    association :licensable, factory: :metasploit_cache_exploit_instance
  end

  factory :metasploit_cache_nop_license,
          class: Metasploit::Cache::Licensable::License,
          traits: [:metasploit_cache_licensable_license] do

    association :licensable, factory: :metasploit_cache_nop_instance
  end

  factory :metasploit_cache_payload_single_license,
          class: Metasploit::Cache::Licensable::License,
          traits: [:metasploit_cache_licensable_license] do

    association :licensable, factory: :metasploit_cache_payload_single_instance
  end

  trait :metasploit_cache_licensable_license do
    association :license, factory: :metasploit_cache_license
  end

end