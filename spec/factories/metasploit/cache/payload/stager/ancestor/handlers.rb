FactoryGirl.define do
  #
  # Factories
  #

  factory :metasploit_cache_payload_stager_ancestor_handler,
          class: Metasploit::Cache::Payload::Stager::Ancestor::Handler do
    #
    # Associations
    #

    association :payload_stager_ancestor,
                factory: :metasploit_cache_payload_stager_ancestor

    #
    # Attributes
    #

    type_alias { generate :metasploit_cache_payload_stager_ancestor_handler_type_alias }
  end

  #
  # Sequences
  #

  sequence :metasploit_cache_payload_stager_ancestor_handler_type_alias do |n|
    "metasploit_cache_payload_stager_ancestor_handler_type_alias#{n}"
  end
end