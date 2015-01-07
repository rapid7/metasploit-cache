require 'spec_helper'

RSpec.describe 'db/seeds.rb' do
  def seed
    load Metasploit::Cache::Engine.root.join('db', 'seeds.rb')
  end

  it_should_behave_like 'MetasploitDataModels db/seeds.rb'
end