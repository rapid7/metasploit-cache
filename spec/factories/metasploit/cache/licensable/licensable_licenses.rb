FactoryGirl.define do
  trait :metasploit_cache_licensable_licensable_licenses do
    transient do
      licensable_license_count 1
    end

    after(:build) do |licensable, evaluator|
      licensable.licensable_licenses = build_list(
          :metasploit_cache_licensable_license,
          evaluator.licensable_license_count,
          licensable: licensable
      )
    end
  end
end