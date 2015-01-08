RSpec.describe 'db/seeds.rb' do
  def seed
    load Metasploit::Cache::Engine.root.join('db', 'seeds.rb')
  end

  it_should_behave_like 'Metasploit::Cache db/seeds.rb'
end