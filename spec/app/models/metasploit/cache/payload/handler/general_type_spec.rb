RSpec.describe Metasploit::Cache::Payload::Handler::GeneralType do
  context 'CONSTANTS' do
    context 'ALL' do
      subject(:all) {
        described_class::ALL
      }

      it { is_expected.to include('bind') }
      it { is_expected.to include('find') }
      it { is_expected.to include('none') }
      it { is_expected.to include('reverse') }
      it { is_expected.to include('tunnel') }
    end

    context 'bind' do
      subject(:bind) {
        described_class::BIND
      }

      it { is_expected.to eq('bind') }
    end

    context 'find' do
      subject(:find) {
        described_class::FIND
      }

      it { is_expected.to eq('find') }
    end

    context 'none' do
      subject(:none) {
        described_class::NONE
      }

      it { is_expected.to eq('none') }
    end

    context 'reverse' do
      subject(:reverse) {
        described_class::REVERSE
      }

      it { is_expected.to eq('reverse') }
    end

    context 'tunnel' do
      subject(:tunnel) {
        described_class::TUNNEL
      }

      it { is_expected.to eq('tunnel') }
    end
  end
end