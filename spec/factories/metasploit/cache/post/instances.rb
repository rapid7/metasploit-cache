FactoryGirl.define do
  factory :metasploit_cache_post_instance,
          class: Metasploit::Cache::Post::Instance,
          traits: [
              :metasploit_cache_contributable_contributions,
              :metasploit_cache_licensable_licensable_licenses,
              :metasploit_cache_platformable_platformable_platforms
          ] do
    description { generate :metasploit_cache_post_instance_description }
    disclosed_on { generate :metasploit_cache_post_instance_disclosed_on }
    name { generate :metasploit_cache_post_instance_name }
    privileged { generate :metasploit_cache_post_instance_privileged }

    #
    # Associations
    #

    association :post_class, factory: :metasploit_cache_post_class
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