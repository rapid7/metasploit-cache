FactoryGirl.define do
  factory :metasploit_cache_licensable_license,
          class: Metasploit::Cache::Licensable::License do
    # @note Factory is invalid unless caller sets licensable
    licensable nil

    association :license, factory: :metasploit_cache_license

    factory :metasploit_cache_auxiliary_license do
      association :licensable, factory: :metasploit_cache_auxiliary_instance
    end

    factory :metasploit_cache_encoder_license do
      association :licensable, factory: :metasploit_cache_encoder_instance
    end

    factory :metasploit_cache_exploit_license do
      association :licensable, factory: :metasploit_cache_exploit_instance
    end

    factory :metasploit_cache_nop_license do
      association :licensable, factory: :metasploit_cache_nop_instance
    end

    factory :metasploit_cache_payload_single_license do
      association :licensable, factory: :metasploit_cache_payload_single_instance
    end

    factory :metasploit_cache_payload_stage_license do
      association :licensable, factory: :metasploit_cache_payload_stage_instance
    end

    factory :metasploit_cache_payload_stager_license do
      association :licensable, factory: :metasploit_cache_payload_stager_instance
    end

    factory :metasploit_cache_post_license do
      association :licensable, factory: :metasploit_cache_post_instance
    end
  end
end