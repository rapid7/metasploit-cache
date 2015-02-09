FactoryGirl.define do
  sequence :metasploit_cache_author_name do |n|
    "Metasploit::Cache::Author #{n}"
  end

  trait :metasploit_cache_author do
    name { generate :metasploit_cache_author_name }
  end
end