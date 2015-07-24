FactoryGirl.define do
  #
  # Factories
  #

  factory :metasploit_cache_architecturable_architecture,
          class: Metasploit::Cache::Architecturable::Architecture do
    # @note This factory is invalid unless `architecturable` is set by the caller
    architecturable { nil }

    architecture { generate :metasploit_cache_architecture }

    factory :metasploit_cache_encoder_architecture do
      association :architecturable, factory: :metasploit_cache_encoder_instance
    end

    factory  :metasploit_cache_exploit_target_architecture do
      association :architecturable, factory: :metasploit_cache_exploit_target
    end

    factory :metasploit_cache_nop_architecture do
      association :architecturable, factory: :metasploit_cache_nop_instance
    end

    factory :metasploit_cache_payload_single_architecture do
      association :architecturable, factory: :metasploit_cache_payload_single_instance
    end

    factory :metasploit_cache_payload_stage_architecture do
      association :architecturable, factory: :metasploit_cache_payload_stage_instance
    end

    factory :metasploit_cache_payload_stager_architecture do
      association :architecturable, factory: :metasploit_cache_payload_stager_instance
    end

    factory :metasploit_cache_post_architecture do
      association :architecturable, factory: :metasploit_cache_post_instance
    end
  end
end