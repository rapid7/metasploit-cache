RSpec.describe Metasploit::Cache::Module::Stance do
  context 'CONSTANTS' do
    context 'ALL' do
      subject(:all) do
        described_class::ALL
      end

      it { should include(described_class::AGGRESSIVE) }
      it { should include(described_class::PASSIVE) }
    end

    context 'AGGRESSIVE' do
      subject(:aggressive) do
        described_class::AGGRESSIVE
      end

      it { should == 'aggressive' }
    end

    context 'PASSIVE' do
      subject(:passive) do
        described_class::PASSIVE
      end

      it { should == 'passive' }
    end

    context 'PRECEDENCE' do
      subject(:precedence) {
        described_class::PRECEDENCE
      }

      it 'should list AGGRESSIVE before PASSIVE' do
        expect(precedence).to eq [
                                     described_class::AGGRESSIVE,
                                     described_class::PASSIVE
                                 ]
      end
    end
  end
end