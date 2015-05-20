FactoryGirl.define do
  factory :metasploit_cache_payload_stage_instance,
          class: Metasploit::Cache::Payload::Stage::Instance do
    transient do
      platformable_platform_count { 1 }
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

    after(:build) do |payload_stage_instance, evaluator|
      payload_stage_instance.platformable_platforms = build_list(
          :metasploit_cache_payload_stage_platform,
          evaluator.platformable_platform_count,
          platformable: payload_stage_instance
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