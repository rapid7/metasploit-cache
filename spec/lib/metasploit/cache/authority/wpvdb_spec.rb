RSpec.describe Metasploit::Cache::Authority::Wpvdb do
  context 'designation_url' do
    subject(:designation_url) {
      described_class.designation_url(designation)
    }

    let(:designation) {
      FactoryGirl.generate :metasploit_cache_reference_edb_designation
    }

    it 'is under vulnerabilities directory' do
      expect(designation_url).to eq("https://wpvulndb.com/vulnerabilities/#{designation}")
    end
  end
end