FactoryGirl.define do
  factory :metasploit_cache_nop_instance,
          class: Metasploit::Cache::Nop::Instance,
          traits: [
              :metasploit_cache_architecturable_architecturable_architectures,
              :metasploit_cache_contributable_contributions,
              :metasploit_cache_licensable_licensable_licenses,
              :metasploit_cache_platformable_platformable_platforms
          ] do
    description { generate :metasploit_cache_nop_instance_description }
    name { generate :metasploit_cache_nop_instance_name }

    #
    # Associations
    #

    association :nop_class, factory: :metasploit_cache_nop_class
  end

  #
  # Sequences
  #

  sequence(:metasploit_cache_nop_instance_description) { |n|
    "Metasploit::Cache::Nop::Instance#description #{n}"
  }

  sequence(:metasploit_cache_nop_instance_name) { |n|
    "Metasploit::Cache::Nop::Instance#name #{n}"
  }
end