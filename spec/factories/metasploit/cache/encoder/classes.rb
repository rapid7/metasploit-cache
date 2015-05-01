FactoryGirl.define do
  factory :metasploit_cache_encoder_class,
          class: Metasploit::Cache::Encoder::Class,
          traits: [
              :metasploit_cache_direct_class,
              :metasploit_cache_direct_class_ancestor_contents
          ] do
    #
    # Associations
    #

    association :ancestor, factory: :metasploit_cache_encoder_ancestor
  end
end