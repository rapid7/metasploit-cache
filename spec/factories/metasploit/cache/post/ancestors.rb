FactoryGirl.define do
  factory :metasploit_cache_post_ancestor,
          class: Metasploit::Cache::Post::Ancestor,
          traits: [:metasploit_cache_module_ancestor] do
    transient do
      module_type { 'post' }
    end
  end
end