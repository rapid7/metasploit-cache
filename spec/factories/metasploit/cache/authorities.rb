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

  seeded_abbreviations = Metasploit::Cache::Authority::Seed::ATTRIBUTES.map { |attributes|
    attributes[:abbreviation]
  }

  seeded_abbreviation_count = seeded_abbreviations.length

  sequence :seeded_metasploit_cache_authority do |n|
    abbreviation = seeded_abbreviations[n % seeded_abbreviation_count]

    authority = Metasploit::Cache::Authority.where(abbreviation: abbreviation).first

    unless authority
      raise ArgumentError,
            "Metasploit::Cache::Authority with abbreviation (#{abbreviation}) has not been seeded."
    end

    authority
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