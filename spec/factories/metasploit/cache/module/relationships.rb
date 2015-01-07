FactoryGirl.define do
  factory :metasploit_cache_module_relationship, class: Metasploit::Cache::Module::Relationship do
    association :descendant, factory: :metasploit_cache_module_class
    association :ancestor, factory: :metasploit_cache_module_ancestor
  end
end