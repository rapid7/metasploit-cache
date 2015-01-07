FactoryGirl.define do
  factory :metasploit_cache_authority,
          class: Metasploit::Cache::Authority do
    abbreviation { generate :metasploit_cache_authority_abbreviation }

    factory :full_metasploit_cache_authority do
      summary { generate :metasploit_cache_authority_summary }
      url { generate :metasploit_cache_authority_url }
    end

    factory :obsolete_metasploit_cache_authority do
      obsolete { true }
    end
  end

  seeded_abbreviations = [
      'BID',
      'CVE',
      'MIL',
      'MSB',
      'OSVDB',
      'PMASA',
      'SECUNIA',
      'US-CERT-VU',
      'waraxe'
  ]
  seeded_abbreviation_count = seeded_abbreviations.length

  sequence :seeded_metasploit_cache_authority do |n|
    abbreviation = seeded_abbreviations[n % seeded_abbreviation_count]

    Metasploit::Cache::Authority.where(:abbreviation => abbreviation).first
  end

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
end