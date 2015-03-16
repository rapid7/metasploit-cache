FactoryGirl.define do
  factory :metasploit_cache_payload_single_ancestor,
          class: Metasploit::Cache::Payload::Single::Ancestor,
          traits: [
              :metasploit_cache_payload_ancestor,
              :metasploit_cache_payload_ancestor_content
          ] do
    transient do
      payload_type { 'single' }
    end
  end
end