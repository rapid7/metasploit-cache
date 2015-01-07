FactoryGirl.define do
  factory :metasploit_cache_module_reference, class: Metasploit::Cache::Module::Reference do
    #
    # Associations
    #

    association :module_instance, factory: :metasploit_cache_module_instance
    association :reference, factory: :metasploit_cache_reference
  end
end