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
                :metasploit_cache_auxiliary_class_name,
                :metasploit_cache_direct_class_ancestor_contents
            ]
  end


  #
  # Traits
  #

  trait :metasploit_cache_auxiliary_class_name do
    after(:build) do |auxiliary_class, _evaluator|
      auxiliary_class.build_name(
          module_type: 'auxiliary',
          reference: auxiliary_class.reference_name
      )
    end
  end
end