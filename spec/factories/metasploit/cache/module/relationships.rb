FactoryGirl.define do
  factory :metasploit_cache_module_relationship, class: Metasploit::Cache::Module::Relationship do
    association :descendant, factory: :metasploit_cache_module_class
    ancestor {
      factory = generate :metasploit_cache_module_ancestor_factory

      FactoryGirl.build(factory)
    }
  end
end