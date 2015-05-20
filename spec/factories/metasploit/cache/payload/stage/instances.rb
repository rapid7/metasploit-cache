FactoryGirl.define do
  factory :metasploit_cache_payload_stage_instance,
          class: Metasploit::Cache::Payload::Stage::Instance do
    transient do
      licenses_count 1
    end

    description { generate :metasploit_cache_payload_stage_instance_description }
    name { generate :metasploit_cache_payload_stage_instance_name }
    privileged { generate :metasploit_cache_payload_stage_instance_privileged }

    #
    # Associations
    #
    association :payload_stage_class, factory: :metasploit_cache_payload_stage_class


    #
    # Callbacks
    #
    after(:build) do |stage_instance, evaluator|
      stage_instance.licensable_licenses = build_list(
        :metasploit_cache_payload_stage_license,
        evaluator.licenses_count,
        licensable: stage_instance
      )
    end
  end

  #
  # Sequences
  #

  sequence(:metasploit_cache_payload_stage_instance_description) { |n|
    "Metasploit::Cache::Payload::Stage::Instance#description #{n}"
  }

  sequence(:metasploit_cache_payload_stage_instance_name) { |n|
    "Metasploit::Cache::Payload::Stage::Instance#name #{n}"
  }

  sequence :metasploit_cache_payload_stage_instance_privileged, Metasploit::Cache::Spec.sample_stream([false, true])
end