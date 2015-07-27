FactoryGirl.define do
  factory :metasploit_cache_payload_single_instance,
          class: Metasploit::Cache::Payload::Single::Instance,
          traits: [
              :metasploit_cache_architecturable_architecturable_architectures
          ] do
    transient do
      contribution_count 1
      architecturable_architecture_count 1
      licensable_license_count 1
      platformable_platform_count 1
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
      payload_single_instance.contributions = build_list(
        :metasploit_cache_payload_single_contribution,
        evaluator.contribution_count,
        contributable: payload_single_instance
      )
      
      payload_single_instance.licensable_licenses = build_list(
        :metasploit_cache_payload_single_license,
        evaluator.licensable_license_count,
        licensable: payload_single_instance
      )
      
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