FactoryGirl.define do
  factory :metasploit_cache_email_address,
          class: Metasploit::Cache::EmailAddress do
    domain { generate :metasploit_cache_email_address_domain }
    local { generate :metasploit_cache_email_address_local }
  end

  sequence :metasploit_cache_email_address_domain do |n|
    "metasploit-cache-email-address-domain#{n}.com"
  end

  sequence :metasploit_cache_email_address_local do |n|
    "metasploit.cache.email.address.local+#{n}"
  end
end