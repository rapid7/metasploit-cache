FactoryGirl.define do
  factory :metasploit_cache_module_author, class: Metasploit::Cache::Module::Author do
    association :author, factory: :metasploit_cache_author
    association :module_instance, factory: :metasploit_cache_module_instance

    factory :full_metasploit_cache_module_author do
      association :email_address, factory: :metasploit_cache_email_address
    end
  end
end