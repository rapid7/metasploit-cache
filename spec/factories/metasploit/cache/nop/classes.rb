FactoryGirl.define do
  #
  # Factories 
  #
  factory :metasploit_cache_nop_class,
          class: Metasploit::Cache::Nop::Class,
          traits: [
              :metasploit_cache_direct_class
          ] do
    #
    # Associations
    #

    association :ancestor, factory: :metasploit_cache_nop_ancestor

    factory :full_metasploit_cache_nop_class,
            traits: [
                :metasploit_cache_nop_class_name,
                :metasploit_cache_direct_class_ancestor_contents
            ]
  end
   
  #
  # Traits
  #
  
  trait :metasploit_cache_nop_class_name do
    after(:build) do |nop_class, _evaluator|
      nop_class.build_name(
          module_type: 'nop',
          reference: nop_class.reference_name
      )
    end
  end 
end