FactoryGirl.define do
  factory :metasploit_cache_module_action,
          class: Metasploit::Cache::Module::Action do
    #
    # Associations
    #

    association :module_instance, :factory => :metasploit_cache_module_instance

    #
    # Attributes
    #

    name { generate :metasploit_cache_module_action_name }
  end

  sequence :metasploit_cache_module_action_name do |n|
    "Metasploit::Cache::Module::Action#name #{n}"
  end
end