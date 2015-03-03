FactoryGirl.define do
  factory :metasploit_cache_payload_stage_ancestor,
          class: Metasploit::Cache::Payload::Stage::Ancestor,
          parent: :metasploit_cache_payload_ancestor do
    transient do
      payload_type { 'stage' }
    end
  end
end