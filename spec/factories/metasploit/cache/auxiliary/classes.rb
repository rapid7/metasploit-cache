FactoryGirl.define do
  factory :metasploit_cache_auxiliary_class,
          class: Metasploit::Cache::Auxiliary::Class,
          traits: [
              :metasploit_cache_direct_class,
              :metasploit_cache_direct_class_ancestor_content
          ] do
    #
    # Associations
    #

    association :ancestor, factory: :metasploit_cache_auxiliary_ancestor
  end
end