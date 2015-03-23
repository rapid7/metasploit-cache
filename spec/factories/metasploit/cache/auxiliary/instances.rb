FactoryGirl.define do
  factory :metasploit_cache_auxiliary_instance,
          class: Metasploit::Cache::Auxiliary::Instance do
    #
    # Associations
    #

    association :auxiliary_class, factory: :metasploit_cache_auxiliary_class
  end
end