FactoryGirl.define do
  factory :metasploit_cache_nop_ancestor,
          class: Metasploit::Cache::Nop::Ancestor,
          parent: :metasploit_cache_module_ancestor do
    transient do
      module_type { 'nop' }
    end
  end
end