FactoryGirl.define do
  factory :metasploit_cache_post_class,
          class: Metasploit::Cache::Post::Class,
          traits: [
              :metasploit_cache_direct_class,
              :metasploit_cache_direct_class_ancestor_contents
          ] do
    #
    # Associations
    #

    association :ancestor, factory: :metasploit_cache_post_ancestor
  end
end