Metasploit::Cache::Architecture::Seed.seed
Metasploit::Cache::Authority::Seed.seed
Metasploit::Cache::Platform::Seed.seed

Metasploit::Cache::Module::Rank::NUMBER_BY_NAME.each do |name, number|
  Metasploit::Cache::Module::Rank.where(:name => name, :number => number).first_or_create!
end