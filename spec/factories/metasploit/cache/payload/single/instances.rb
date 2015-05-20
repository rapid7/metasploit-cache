FactoryGirl.define do
  factory :metasploit_cache_payload_single_instance,
          class: Metasploit::Cache::Payload::Single::Instance do
    transient do
      platformable_platform_count { 1 }
    end

    description { generate :metasploit_cache_payload_single_instance_description }
    name { generate :metasploit_cache_payload_single_instance_name }
    privileged { generate :metasploit_cache_payload_single_instance_privileged }

    #
    # Associations
    #

    association :handler, factory: :metasploit_cache_payload_handler
    association :payload_single_class, factory: :metasploit_cache_payload_single_class
    
    #
    # Callbacks
    #

    after(:build) do |payload_single_instance, evaluator|
      payload_single_instance.platformable_platforms = build_list(
          :metasploit_cache_payload_single_platform,
          evaluator.platformable_platform_count,
          platformable: payload_single_instance
      )
    end
  end

  #
  # Sequences
  #

  sequence(:metasploit_cache_payload_single_instance_description) { |n|
    "Metasploit::Cache::Payload::Single::Instance#description #{n}"
  }

  sequence(:metasploit_cache_payload_single_instance_name) { |n|
    "Metasploit::Cache::Payload::Single::Instance#name #{n}"
  }

  sequence :metasploit_cache_payload_single_instance_privileged, Metasploit::Cache::Spec.sample_stream([false, true])
end