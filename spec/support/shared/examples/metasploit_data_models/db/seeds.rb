shared_examples_for 'MetasploitDataModels db/seeds.rb' do
  # undo seeding done for suite
  before(:each) do
    Metasploit::Cache::Architecture.delete_all
    Metasploit::Cache::Authority.delete_all
    Metasploit::Cache::Platform.delete_all
    Metasploit::Cache::Module::Rank.delete_all
  end

  it 'should seed Metasploit::Cache::Architecture' do
    expect {
      seed
    }.to change(Metasploit::Cache::Architecture, :count)
  end

  it 'should seed Metasploit::Cache::Authority' do
    expect {
      seed
    }.to change(Metasploit::Cache::Authority, :count)
  end

  it 'should seed Metasploit::Cache::Platform' do
    expect {
      seed
    }.to change(Metasploit::Cache::Platform, :count)
  end

  it 'should seed Metasploit::Cache::Rank' do
    expect {
      seed
    }.to change(Metasploit::Cache::Module::Rank, :count)
  end

  context 'when run twice' do
    before(:each) do
      seed
    end

    it 'should not raise error' do
      expect {
        seed
      }.to_not raise_error
    end

    it 'should not seed new Metasploit::Cache::Architectures' do
      expect {
        seed
      }.not_to change(Metasploit::Cache::Architecture, :count)
    end

    it 'should not seed new Metasploit::Cache::Authorities' do
      expect {
        seed
      }.not_to change(Metasploit::Cache::Authority, :count)
    end

    it 'should not seed new Metasploit::Cache::Platforms' do
      expect {
        seed
      }.not_to change(Metasploit::Cache::Platform, :count)
    end

    it 'should not seed new Metasploit::Cache::Ranks' do
      expect {
        seed
      }.not_to change(Metasploit::Cache::Module::Rank, :count)
    end
  end
end