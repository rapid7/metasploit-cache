FactoryGirl.define do
  factory :metasploit_cache_licensable_license,
          class: Metasploit::Cache::Licensable::License do
    # @note Factory is invalid unless caller sets licensable
    licensable nil

    association :license, factory: :metasploit_cache_license
  end
end