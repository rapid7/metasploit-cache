FactoryGirl.define do
  #
  # Factories
  #

  factory :metasploit_cache_encoder_instance,
          class: Metasploit::Cache::Encoder::Instance do
    transient do
      platformable_platform_count { 1 }
    end

    description { generate :metasploit_cache_encoder_instance_description }
    name { generate :metasploit_cache_encoder_instance_name }

    #
    # Associations
    #

    association :encoder_class, factory: :metasploit_cache_encoder_class

    #
    # Callbacks
    #

    after(:build) do |encoder_instance, evaluator|
      encoder_instance.platformable_platforms = build_list(
          :metasploit_cache_encoder_platform,
          evaluator.platformable_platform_count,
          platformable: encoder_instance
      )
    end
  end

  #
  # Sequences
  #

  sequence :metasploit_cache_encoder_instance_description do |n|
    "Metasploit::Cache::Encoder::Instance#description #{n}"
  end

  sequence :metasploit_cache_encoder_instance_name do |n|
    "Metasploit::Cache::Encoder::Instance#name #{n}"
  end
end