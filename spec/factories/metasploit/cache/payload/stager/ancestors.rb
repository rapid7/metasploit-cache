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

    factory :full_metasploit_cache_payload_stager_ancestor do
      after(:build) do |payload_stager_ancestor, _evaluator|
        payload_stager_ancestor.handler = build(
            :metasploit_cache_payload_stager_ancestor_handler,
            payload_stager_ancestor: payload_stager_ancestor
        )
      end
    end
  end
end