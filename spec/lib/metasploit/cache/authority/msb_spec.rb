require 'spec_helper'

RSpec.describe Metasploit::Cache::Authority::Msb do
  context 'designation_url' do
    subject(:designation_url) do
      described_class.designation_url(designation)
    end

    let(:designation) do
      FactoryGirl.generate :metasploit_cache_reference_msb_designation
    end

    it 'should be under security bulletins' do
      expect(designation_url).to eq("http://www.microsoft.com/technet/security/bulletin/#{designation}")
    end
  end
end