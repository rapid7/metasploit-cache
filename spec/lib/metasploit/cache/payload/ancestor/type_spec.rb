RSpec.describe Metasploit::Cache::Payload::Ancestor::Type do
  context 'CONSTANTS' do
    context 'ALL' do
      subject(:all) {
        described_class::ALL
      }

      it { is_expected.to include('single') }
      it { is_expected.to include('stage') }
      it { is_expected.not_to include('staged') }
      it { is_expected.to include('stager') }
    end

    context 'SINGLE' do
      subject(:single) {
        described_class::SINGLE
      }

      it { is_expected.to eq('single') }
    end

    context 'STAGE' do
      subject(:stage) {
        described_class::STAGE
      }

      it { is_expected.to eq('stage') }
    end

    context 'STAGER' do
      subject(:stager) {
        described_class::STAGER
      }

      it { is_expected.to eq('stager') }
    end
  end

  context 'sequences' do
    context 'metasploit_cache_payload_ancestor_type' do
      subject(:metasploit_cache_payload_ancestor_type) {
        FactoryGirl.generate :metasploit_cache_payload_ancestor_type
      }

      it 'generates payload type from Metasploit::Cache::Payload::Ancestor::Type::ALL' do
        expect(described_class::ALL).to include(metasploit_cache_payload_ancestor_type)
      end
    end
  end
end