FactoryGirl.define do
  factory :metasploit_cache_payload_stager_ancestor,
          class: Metasploit::Cache::Payload::Stager::Ancestor,
          parent: :metasploit_cache_payload_ancestor do
    transient do
      payload_type { 'stager' }
    end
  end
end