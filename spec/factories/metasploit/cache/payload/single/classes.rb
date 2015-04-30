FactoryGirl.define do
  factory :metasploit_cache_payload_single_class,
          class: Metasploit::Cache::Payload::Single::Class,
          traits: [
              :metasploit_cache_payload_direct_class,
              :metasploit_cache_payload_direct_class_ancestor_contents
          ] do
    #
    # Associations
    #

    association :ancestor, factory: :metasploit_cache_payload_single_ancestor
  end
end