FactoryGirl.define do
  factory :metasploit_cache_auxiliary_ancestor,
          class: Metasploit::Cache::Auxiliary::Ancestor,
          parent: :metasploit_cache_module_ancestor do
    transient do
      module_type { 'auxiliary' }
    end
  end
end