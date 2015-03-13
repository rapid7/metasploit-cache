FactoryGirl.define do
  factory :metasploit_cache_auxiliary_ancestor,
          class: Metasploit::Cache::Auxiliary::Ancestor,
          traits: [
              :metasploit_cache_module_ancestor,
              :metasploit_cache_module_ancestor_content
          ] do
    transient do
      module_type { 'auxiliary' }
    end
  end
end