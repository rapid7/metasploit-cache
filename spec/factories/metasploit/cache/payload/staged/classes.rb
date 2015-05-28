FactoryGirl.define do
  factory :metasploit_cache_payload_staged_class,
          class: Metasploit::Cache::Payload::Staged::Class do
    association :payload_stage_instance, factory: :metasploit_cache_payload_stage_instance
    association :payload_stager_instance, factory: :metasploit_cache_payload_stager_instance
  end
end