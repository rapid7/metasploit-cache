FactoryGirl.define do
  factory :metasploit_cache_payload_stage_ancestor,
          class: Metasploit::Cache::Payload::Stage::Ancestor,
          traits: [
              :metasploit_cache_payload_ancestor,
              :metasploit_cache_payload_ancestor_contents
          ] do
    transient do
      payload_type { 'stage' }
    end
  end
end