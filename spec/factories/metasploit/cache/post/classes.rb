FactoryGirl.define do
  #
  # Factories
  #
  
  factory :metasploit_cache_post_class,
          class: Metasploit::Cache::Post::Class,
          traits: [
              :metasploit_cache_direct_class
          ] do
    #
    # Associations
    #

    association :ancestor, factory: :metasploit_cache_post_ancestor

    factory :full_metasploit_cache_post_class,
            traits: [
                :metasploit_cache_post_class_name,
                :metasploit_cache_direct_class_ancestor_contents
            ]
  end
  
  #
  # Traits
  #
  
  trait :metasploit_cache_post_class_name do
    after(:build) do |post_class, _evaluator|
      post_class.build_name(
          module_type: 'post',
          reference: post_class.reference_name
      )
    end
  end
end