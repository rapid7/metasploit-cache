FactoryGirl.define do
  factory :metasploit_cache_platformable_platform,
          class: Metasploit::Cache::Platformable::Platform do
    platform { generate :metasploit_cache_platform }

    # @note factory is invalid unless caller set platformable
    platformable nil

    factory :metasploit_cache_encoder_platform do
      association :platformable, factory: :metasploit_cache_encoder_instance
    end

    factory :metasploit_cache_exploit_target_platform do
      association :platformable, factory: :metasploit_cache_exploit_target
    end

    factory :metasploit_cache_nop_platform do
      association :platformable, factory: :metasploit_cache_nop_instance
    end

    factory :metasploit_cache_payload_single_platform do
      association :platformable, factory: :metasploit_cache_payload_single_instance
    end

    factory :metasploit_cache_payload_stage_platform do
      association :platformable, factory: :metasploit_cache_payload_stage_instance
    end

    factory :metasploit_cache_payload_stager_platform do
      association :platformable, factory: :metasploit_cache_payload_stager_instance
    end

    factory :metasploit_cache_post_platform do
      association :platformable, factory: :metasploit_cache_post_instance
    end
  end
end