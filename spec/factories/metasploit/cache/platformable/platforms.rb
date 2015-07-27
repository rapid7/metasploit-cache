FactoryGirl.define do
  factory :metasploit_cache_platformable_platform,
          class: Metasploit::Cache::Platformable::Platform do
    platform { generate :metasploit_cache_platform }

    # @note factory is invalid unless caller set platformable
    platformable nil
  end
end