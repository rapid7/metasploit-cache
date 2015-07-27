FactoryGirl.define do
  factory :metasploit_cache_payload_stage_instance,
          class: Metasploit::Cache::Payload::Stage::Instance,
          traits: [
              :metasploit_cache_architecturable_architecturable_architectures,
              :metasploit_cache_contributable_contributions,
              :metasploit_cache_licensable_licensable_licenses,
              :metasploit_cache_platformable_platformable_platforms
          ] do
    description { generate :metasploit_cache_payload_stage_instance_description }
    name { generate :metasploit_cache_payload_stage_instance_name }
    privileged { generate :metasploit_cache_payload_stage_instance_privileged }

    #
    # Associations
    #

    association :payload_stage_class, factory: :metasploit_cache_payload_stage_class
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