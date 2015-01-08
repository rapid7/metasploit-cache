RSpec.describe Metasploit::Cache::Authority::Secunia do
  context 'designation_url' do
    subject(:designation_url) do
      described_class.designation_url(designation)
    end

    let(:designation) do
      FactoryGirl.generate :metasploit_cache_reference_secunia_designation
    end

    it 'should be under advisories directory' do
      expect(designation_url).to eq("https://secunia.com/advisories/#{designation}/")
    end
  end
end