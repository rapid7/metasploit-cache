FactoryGirl.define do
  factory :metasploit_cache_nop_ancestor,
          class: Metasploit::Cache::Nop::Ancestor,
          traits: [
              :metasploit_cache_module_ancestor,
              :metasploit_cache_module_ancestor_contents
          ] do
    transient do
      module_type { 'nop' }
    end
  end
end