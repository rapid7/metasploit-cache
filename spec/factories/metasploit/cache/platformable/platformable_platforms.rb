FactoryGirl.define do
  trait :metasploit_cache_platformable_platformable_platforms do
    transient do
      platformable_platform_count 1
    end

    after(:build) do |platforamble, evaluator|
      platforamble.platformable_platforms = build_list(
          :metasploit_cache_platformable_platform,
          evaluator.platformable_platform_count,
          platformable: platforamble
      )
    end
  end
end