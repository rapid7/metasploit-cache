FactoryGirl.define do
  #
  # Factories
  #
  
  factory :metasploit_cache_encoder_class,
          class: Metasploit::Cache::Encoder::Class,
          traits: [
              :metasploit_cache_direct_class
          ] do
    #
    # Associations
    #

    association :ancestor, factory: :metasploit_cache_encoder_ancestor

    factory :full_metasploit_cache_encoder_class,
            traits: [
                :metasploit_cache_encoder_class_name,
                :metasploit_cache_direct_class_ancestor_contents
            ]
  end
  
  #
  # Traits
  #
  
  trait :metasploit_cache_encoder_class_name do
    after(:build) do |encoder_class, _evaluator|
      encoder_class.build_name(
          module_type: 'encoder',
          reference: encoder_class.reference_name
      )
    end
  end
end