FactoryGirl.define do
  factory :metasploit_cache_license, class: Metasploit::Cache::License do
    abbreviation { generate :metasploit_cache_license_abbreviation }
    summary { generate :metasploit_cache_license_summary }
    url { generate :metasploit_cache_license_url }
  end

  sequence :metasploit_cache_license_abbreviation do |n|
    "BSD-#{n}"
  end

  sequence :metasploit_cache_license_summary do |n|
      <<EOS
#{n}-Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
EOS
  end

  sequence :metasploit_cache_license_url do |n|
    "http://opensource.org/licenses/BSD-#{n}-Clause"
  end
end