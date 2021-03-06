FactoryGirl.define do
  factory :metasploit_cache_payload_stager_class,
          class: Metasploit::Cache::Payload::Stager::Class,
          traits: [
              :metasploit_cache_payload_unhandled_class,
              :metasploit_cache_payload_unhandled_class_ancestor_contents
          ] do
    #
    # Associations
    #

    association :ancestor, factory: :metasploit_cache_payload_stager_ancestor
  end
end