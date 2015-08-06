RSpec.describe Metasploit::Cache::Authority::Cwe do
  context 'designation_url' do
    subject(:designation_url) {
      described_class.designation_url(designation)
    }

    let(:designation) {
      FactoryGirl.generate :metasploit_cache_reference_cwe_designation
    }

    it 'is under definitions directory' do
      expect(designation_url).to eq("https://cwe.mitre.org/data/definitions/#{designation}.html")
    end
  end
end