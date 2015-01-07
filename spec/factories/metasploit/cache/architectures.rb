FactoryGirl.define do
  abbreviations = Metasploit::Cache::Architecture::ABBREVIATIONS

  # metasploit_cache_architectures is not a factory, but a sequence because only the seeded
  # Metasploit::Cache::Architectures are valid
  sequence :metasploit_cache_architecture do |n|
    # use abbreviations since they are unique
    abbreviation = abbreviations[n % abbreviations.length]
    architecture = Metasploit::Cache::Architecture.where(:abbreviation => abbreviation).first

    architecture
  end

  sequence :metasploit_cache_architecture_abbreviation, abbreviations.cycle
  sequence :metasploit_cache_architecture_bits, Metasploit::Cache::Architecture::BITS.cycle
  sequence :metasploit_cache_architecture_endianness, Metasploit::Cache::Architecture::ENDIANNESSES.cycle
  sequence :metasploit_cache_architecture_family, Metasploit::Cache::Architecture::FAMILIES.cycle
end