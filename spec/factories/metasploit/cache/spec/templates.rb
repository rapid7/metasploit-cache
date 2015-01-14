FactoryGirl.define do
  factory :metasploit_cache_spec_template,
          class: Metasploit::Cache::Spec::Template,
          traits: [
              :metasploit_model_base
          ] do
    search_pathnames { [] }
  end
end