FactoryGirl.define do
  #
  # Factories
  #

  factory :metasploit_cache_auxiliary_class,
          class: Metasploit::Cache::Auxiliary::Class,
          traits: [
              :metasploit_cache_direct_class
          ] do
    #
    # Associations
    #

    association :ancestor, factory: :metasploit_cache_auxiliary_ancestor

    factory :full_metasploit_cache_auxiliary_class,
            traits: [
                :metasploit_cache_direct_class_ancestor_contents
            ]
  end
end