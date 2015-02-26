FactoryGirl.define do
  factory :metasploit_cache_encoder_ancestor,
          class: Metasploit::Cache::Encoder::Ancestor,
          parent: :metasploit_cache_module_ancestor do
    transient do
      module_type { 'encoder' }
    end
  end
end