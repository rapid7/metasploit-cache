FactoryGirl.define do
  factory :metasploit_cache_post_instance,
          class: Metasploit::Cache::Post::Instance do
    transient do
      licensable_license_count 1
      platformable_platform_count 1
    end

    description { generate :metasploit_cache_post_instance_description }
    disclosed_on { generate :metasploit_cache_post_instance_disclosed_on }
    name { generate :metasploit_cache_post_instance_name }
    privileged { generate :metasploit_cache_post_instance_privileged }

    #
    # Associations
    #

    association :post_class, factory: :metasploit_cache_post_class

    #
    # Callbacks
    #

    after(:build) do |post_instance, evaluator|
      post_instance.licensable_licenses = build_list(
        :metasploit_cache_post_license,
        evaluator.licensable_license_count,
        licensable: post_instance
      )

      post_instance.platformable_platforms = build_list(
          :metasploit_cache_post_platform,
          evaluator.platformable_platform_count,
          platformable: post_instance
      )
    end
  end

  #
  # Sequences
  #

  sequence :metasploit_cache_post_instance_description do |n|
    "Metasploit::Cache::Post::Instance#description #{n}"
  end

  sequence :metasploit_cache_post_instance_disclosed_on do |n|
    n.days.ago
  end

  sequence :metasploit_cache_post_instance_name do |n|
    "Metasploit::Cache::Post::Instance"
  end

  sequence :metasploit_cache_post_instance_privileged, Metasploit::Cache::Spec.sample_stream([false, true])
end