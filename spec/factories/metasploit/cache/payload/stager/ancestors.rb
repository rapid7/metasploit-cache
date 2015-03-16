FactoryGirl.define do
  factory :metasploit_cache_payload_stager_ancestor,
          class: Metasploit::Cache::Payload::Stager::Ancestor,
          traits: [
              :metasploit_cache_payload_ancestor,
              :metasploit_cache_payload_ancestor_contents
          ] do
    transient do
      payload_type { 'stager' }
    end
  end
end