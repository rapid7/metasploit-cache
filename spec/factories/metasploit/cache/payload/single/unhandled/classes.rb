FactoryGirl.define do
  factory :metasploit_cache_payload_single_unhandled_class,
          class: Metasploit::Cache::Payload::Single::Unhandled::Class,
          traits: [
              :metasploit_cache_payload_unhandled_class,
              :metasploit_cache_payload_unhandled_class_ancestor_contents
          ] do
    #
    # Associations
    #

    association :ancestor, factory: :metasploit_cache_payload_single_ancestor
  end
end