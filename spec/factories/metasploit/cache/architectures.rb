FactoryGirl.define do
  sequence :metasploit_cache_architecture_abbreviation, Metasploit::Cache::Architecture::ABBREVIATIONS.cycle
  sequence :metasploit_cache_architecture_bits, Metasploit::Cache::Architecture::BITS.cycle
  sequence :metasploit_cache_architecture_endianness, Metasploit::Cache::Architecture::ENDIANNESSES.cycle
  sequence :metasploit_cache_architecture_family, Metasploit::Cache::Architecture::FAMILIES.cycle
end