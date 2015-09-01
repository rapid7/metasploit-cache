FactoryGirl.define do
  # Metasploit::Cache::Module::Rank does not have a factory because all valid records are seeded, so it only has a
  # sequence to grab a seeded record

  names = Metasploit::Cache::Module::Rank::NUMBER_BY_NAME.keys

  sequence :metasploit_cache_module_rank do |n|
    name = names[n % names.length]

    rank = Metasploit::Cache::Module::Rank.where(name: name).first

    unless rank
      # Ranks will always be seeded before tests start, so this line will only execute if a rank is added without being
      # added to db/seeds.rb
      raise ArgumentError,
            "Metasploit::Cache::Module::Rank with name (#{name}) has not been seeded."
    end

    rank
  end

  number_by_name = Metasploit::Cache::Module::Rank::NUMBER_BY_NAME

  names = number_by_name.keys
  sequence :metasploit_cache_module_rank_name, names.cycle

  numbers = number_by_name.values
  sequence :metasploit_cache_module_rank_number, numbers.cycle
end