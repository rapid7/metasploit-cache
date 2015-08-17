FactoryGirl.define do
  trait :metasploit_cache_payload_handable_handler do
    association :handler, factory: :metasploit_cache_payload_handler
  end
end