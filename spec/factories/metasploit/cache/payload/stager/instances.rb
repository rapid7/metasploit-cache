FactoryGirl.define do
  factory :metasploit_cache_payload_stager_instance,
          class: Metasploit::Cache::Payload::Stager::Instance do
    transient do
      platformable_platform_count { 1 }
    end

    description { generate :metasploit_cache_payload_stager_instance_description }
    handler_type_alias { generate :metasploit_cache_payload_stager_handler_type_alias }
    name { generate :metasploit_cache_payload_stager_instance_name }
    privileged { generate :metasploit_cache_payload_stager_instance_privileged }

    #
    # Associations
    #

    association :handler, factory: :metasploit_cache_payload_handler
    association :payload_stager_class, factory: :metasploit_cache_payload_stager_class

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

  sequence(:metasploit_cache_payload_stager_instance_description) { |n|
    "Metasploit::Cache::Payload::Stager::Instance#description #{n}"
  }

  sequence(:metasploit_cache_payload_stager_handler_type_alias) { |n|
    "metasploit_cache_payload_stager_handler_type_alias#{n}"
  }

  sequence(:metasploit_cache_payload_stager_instance_name) { |n|
    "Metasploit::Cache::Payload::Stager::Instance#name #{n}"
  }

  sequence :metasploit_cache_payload_stager_instance_privileged, Metasploit::Cache::Spec.sample_stream([false, true])
end