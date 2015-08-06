RSpec.describe Metasploit::Cache::Authority::Edb do
  context 'designation_url' do
    subject(:designation_url) {
      described_class.designation_url(designation)
    }

    let(:designation) {
      FactoryGirl.generate :metasploit_cache_reference_edb_designation
    }

    it 'is under exploits directory' do
      expect(designation_url).to eq("https://www.exploit-db.com/exploits/#{designation}")
    end
  end
end