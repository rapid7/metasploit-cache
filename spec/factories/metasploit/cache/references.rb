FactoryGirl.define do
  factory :metasploit_cache_reference,
          class: Metasploit::Cache::Reference do
    #
    # Associations
    #

    association :authority, factory: :metasploit_cache_authority

    #
    # Attributes
    #

    designation { generate :metasploit_cache_reference_designation }
    url { generate :metasploit_cache_reference_url }

    #
    # Child factories
    #

    factory :obsolete_metasploit_cache_reference do
      #
      # Attributes
      #

      url nil
    end

    factory :seeded_authority_metasploit_cache_reference do
      #
      # Associations
      #

      authority { generate :seeded_metasploit_cache_authority }

      #
      # Attributes
      #

      # nil url so that it is derived using authority
      url { nil }
    end

    factory :url_metasploit_cache_reference do
      #
      # Associations
      #

      authority nil

      #
      # Attributes
      #

      designation nil
    end
  end

  #
  #
  # Metasploit::Cache::Reference#designation sequences
  #
  #

  sequence :metasploit_cache_reference_designation do |n|
    n.to_s
  end

  #
  # Metasploit::Cache::Authority-specific Metasploit::Cache::Reference#designation sequences
  #

  sequence :metasploit_cache_reference_bid_designation do |n|
    n.to_s
  end

  sequence :metasploit_cache_reference_cve_designation do |n|
    number = n % 10000
    year = n / 10000

    "%04d-%04d" % [year, number]
  end

  sequence(:metasploit_cache_reference_cwe_designation) { |n|
    n.to_s
  }

  sequence :metasploit_cache_reference_msb_designation do |n|
    number = n % 1000
    year = n / 1000

    "MS%02d-%03d" % [year, number]
  end

  sequence :metasploit_cache_reference_osvdb_designation do |n|
    n.to_s
  end

  sequence :metasploit_cache_reference_pmasa_designation do |n|
    number = n / 100
    year = n / 100

    "#{year}-#{number}"
  end

  sequence :metasploit_cache_reference_secunia_designation do |n|
    n.to_s
  end

  sequence :metasploit_cache_reference_us_cert_vu_designation do |n|
    n.to_s
  end

  sequence :metasploit_cache_reference_waraxe_designation do |n|
    # numbers don't rollover on the year like other authorities
    year = n
    number = n

    "%d-SA#%d" % [year, number]
  end

  sequence :metasploit_cache_reference_zdi_designation do |n|
    year, number = n.divmod(1000)

    "%02d-%03d" % [year, number]
  end

  sequence :metasploit_cache_reference_url do |n|
    "http://example.com/metasploit/cache/reference/#{n}"
  end
end