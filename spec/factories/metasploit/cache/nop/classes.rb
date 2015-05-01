FactoryGirl.define do
  factory :metasploit_cache_nop_class,
          class: Metasploit::Cache::Nop::Class,
          traits: [
              :metasploit_cache_direct_class,
              :metasploit_cache_direct_class_ancestor_contents
          ] do
    #
    # Associations
    #

    association :ancestor, factory: :metasploit_cache_nop_ancestor
  end
end