FactoryGirl.define do
  factory :metasploit_cache_post_ancestor,
          class: Metasploit::Cache::Post::Ancestor,
          traits: [
              :metasploit_cache_module_ancestor,
              :metasploit_cache_module_ancestor_contents
          ] do
    transient do
      module_type { 'post' }
    end
  end
end