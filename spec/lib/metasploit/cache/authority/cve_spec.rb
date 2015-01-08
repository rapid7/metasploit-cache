RSpec.describe Metasploit::Cache::Authority::Cve do
  context 'designation_url' do
    subject(:designation_url) do
      described_class.designation_url(designation)
    end

    let(:designation) do
      FactoryGirl.generate :metasploit_cache_reference_cve_designation
    end

    it 'should be under cve directory' do
      expect(designation_url).to eq("http://cvedetails.com/cve/CVE-#{designation}")
    end
  end
end