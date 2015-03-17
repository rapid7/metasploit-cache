RSpec.describe Metasploit::Cache::Direct::Class::Superclass do
  it 'is a Class' do
    expect(described_class).to be_a Class
  end

  it 'responds to is_usable' do
    expect(described_class).to respond_to :is_usable
  end

  it 'responds to rank' do
    expect(described_class).to respond_to :rank
  end
end