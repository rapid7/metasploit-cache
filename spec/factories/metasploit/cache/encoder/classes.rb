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
                :metasploit_cache_direct_class_ancestor_contents
            ]
  end
end