FactoryGirl.define do
  #
  # Factories
  #

  factory :metasploit_cache_encoder_instance,
          class: Metasploit::Cache::Encoder::Instance do
    description { generate :metasploit_cache_encoder_instance_description }
    name { generate :metasploit_cache_encoder_instance_name }

    transient do
      licensable_license_count 1
    end

    #
    # Associations
    #

    association :encoder_class, factory: :metasploit_cache_encoder_class

    #
    # Callbacks
    #

    after(:build) do |encoder_instance, evaluator|
      encoder_instance.licensable_licenses = build_list(
        :metasploit_cache_encoder_license,
        evaluator.licensable_license_count,
        licensable: encoder_instance
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