FactoryGirl.define do
  #
  # Factories
  #

  factory :metasploit_cache_encoder_instance,
          class: Metasploit::Cache::Encoder::Instance do
    transient do
      architecturable_architecture_count { 1 }
      licensable_license_count 1
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

    after(:build) { |encoder_instance, evaluator|
      encoder_instance.architecturable_architectures = build_list(
          :metasploit_cache_encoder_architecture,
          evaluator.architecturable_architecture_count,
          architecturable: encoder_instance
      )
      encoder_instance.licensable_licenses = build_list(
        :metasploit_cache_encoder_license,
        evaluator.licensable_license_count,
        licensable: encoder_instance
      )
    }
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