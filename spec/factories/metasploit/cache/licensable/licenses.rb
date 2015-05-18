FactoryGirl.define do

  factory :metasploit_cache_auxiliary_instance_license,
                 class: Metasploit::Cache::Licensable::License do
    association :licensable, factory: :metasploit_cache_auxiliary_instance
    association :license, factory: :metasploit_cache_license
  end

end