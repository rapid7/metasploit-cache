FactoryGirl.define do
  factory :metasploit_cache_encoder_ancestor,
          class: Metasploit::Cache::Encoder::Ancestor,
          traits: [
              :metasploit_cache_module_ancestor,
              :metasploit_cache_module_ancestor_content
          ] do
    transient do
      module_type { 'encoder' }
    end
  end
end