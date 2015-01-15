Metasploit::Cache::Architecture::Seed.seed
Metasploit::Cache::Authority::Seed.seed

Metasploit::Cache::Platform.each_seed_attributes do |attributes|
  parent = attributes.fetch(:parent)
  relative_name = attributes.fetch(:relative_name)
  parent_id = nil

  if parent
    parent_id = parent.id
  end

  child = Metasploit::Cache::Platform.where(parent_id: parent_id, relative_name: relative_name).first

  unless child
    child = Metasploit::Cache::Platform.new
    child.parent = parent
    child.relative_name = relative_name
    child.save!
  end

  # yieldreturn
  child
end

Metasploit::Cache::Module::Rank::NUMBER_BY_NAME.each do |name, number|
  Metasploit::Cache::Module::Rank.where(:name => name, :number => number).first_or_create!
end