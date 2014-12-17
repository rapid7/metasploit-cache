require 'spec_helper'

RSpec.describe Metasploit::Model::Authority::Osvdb do
  context 'designation_url' do
    subject(:designation_url) do
      described_class.designation_url(designation)
    end

    let(:designation) do
      FactoryGirl.generate :metasploit_model_reference_osvdb_designation
    end

    it 'should be under advisories directory' do
      expect(designation_url).to eq("http://www.osvdb.org/#{designation}/")
    end
  end
end