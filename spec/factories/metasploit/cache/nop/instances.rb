FactoryGirl.define do
  factory :metasploit_cache_nop_instance,
          class: Metasploit::Cache::Nop::Instance do
    transient do
      licensable_license_count 1
      platformable_platform_count 1
    end

    description { generate :metasploit_cache_nop_instance_description }
    name { generate :metasploit_cache_nop_instance_name }

    #
    # Associations
    #

    association :nop_class, factory: :metasploit_cache_nop_class

    #
    # Callbacks
    #

    after(:build) do |nop_instance, evaluator|
      nop_instance.licensable_licenses = build_list(
        :metasploit_cache_nop_license,
        evaluator.licensable_license_count,
        licensable: nop_instance
      )
      nop_instance.platformable_platforms = build_list(
          :metasploit_cache_nop_platform,
          evaluator.platformable_platform_count,
          platformable: nop_instance
      )
    end
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