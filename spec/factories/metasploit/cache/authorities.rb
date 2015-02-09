FactoryGirl.define do
  sequence :metasploit_cache_authority_abbreviation do |n|
    # can't use '-' as {Metasploit::Cache::Search::Operator::Deprecated::Ref} treats '-' as separating authority
    # abbreviation from reference designation.
    "METASPLOIT_CACHE_AUTHORITY#{n}"
  end

  sequence :metasploit_cache_authority_summary do |n|
    "Metasploit::Cache::Authority #{n}"
  end

  sequence :metasploit_cache_authority_url do |n|
    "http://example.com/metasploit/cache/authority/#{n}"
  end

  trait :metasploit_cache_authority do
    abbreviation { generate :metasploit_cache_authority_abbreviation }
  end

  trait :full_metasploit_cache_authority do
    summary { generate :metasploit_cache_authority_summary }
    url { generate :metasploit_cache_authority_url }
  end

  trait :obsolete_metasploit_cache_authority do
    obsolete { true }
  end
end