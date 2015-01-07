FactoryGirl.define do
  factory :metasploit_cache_author,
          class: Metasploit::Cache::Author do
    name { generate :metasploit_cache_author_name }
  end

  sequence :metasploit_cache_author_name do |n|
    "Metasploit::Cache::Author #{n}"
  end
end