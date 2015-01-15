# Seeds {Metasploit::Cache::Module::Rank Metasploit::Cache::Module::Ranks}.
module Metasploit::Cache::Module::Rank::Seed
  # Seeds {Metasploit::Cache::Module::Rank Metasploit::Cache::Module::Ranks}.
  #
  # @return [void]
  def self.seed
    parent::NUMBER_BY_NAME.each do |name, number|
      parent.where(:name => name, :number => number).first_or_create!
    end
  end
end