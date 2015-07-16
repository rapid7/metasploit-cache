FactoryGirl.define do
  factory :metasploit_cache_payload_staged_instance,
          class: Metasploit::Cache::Payload::Staged::Instance do
    association :payload_staged_class,
                factory: :metasploit_cache_payload_staged_class
  end
end