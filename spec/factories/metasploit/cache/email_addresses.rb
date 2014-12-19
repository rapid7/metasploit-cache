FactoryGirl.define do
  sequence :metasploit_cache_email_address_domain do |n|
    "metasploit-cache-email-address-domain#{n}.com"
  end

  sequence :metasploit_cache_email_address_local do |n|
    "metasploit.cache.email.address.local+#{n}"
  end

  trait :metasploit_cache_email_address do
    domain { generate :metasploit_cache_email_address_domain }
    local { generate :metasploit_cache_email_address_local }
  end
end