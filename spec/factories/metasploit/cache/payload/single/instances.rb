FactoryGirl.define do
  factory :metasploit_cache_payload_single_instance,
          class: Metasploit::Cache::Payload::Single::Instance do
    description { generate :metasploit_cache_payload_single_instance_description }
    name { generate :metasploit_cache_payload_single_instance_name }
    privileged { generate :metasploit_cache_payload_single_instance_privileged }

    #
    # Associations
    #

    association :handler, factory: :metasploit_cache_payload_handler
    association :payload_single_class, factory: :metasploit_cache_payload_single_class
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