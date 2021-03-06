RSpec.describe Metasploit::Cache::Direct::Class::Ranking do
  context 'rank' do
    subject(:rank) {
      subclass.rank
    }

    #
    # lets
    #

    let(:subclass) {
      described_class = self.described_class

      Class.new do
        extend described_class
      end
    }

    #
    # Callbacks
    #

    before(:each) do
      stub_const('RankedSubclass', subclass)
    end

    context 'with Rank' do
      #
      # lets
      #

      let(:rank_constant) {
        # MUST be something other than 'Normal' as 'Normal' is the default without Rank
        Metasploit::Cache::Module::Rank::NUMBER_BY_NAME['Great']
      }

      #
      # Callbacks
      #

      before(:each) do
        stub_const('RankedSubclass::Rank', rank_constant)
      end

      it 'is Rank' do
        expect(rank).to eq(rank_constant)
      end
    end

    context 'without Rank' do
      it 'defaults to Normal number' do
        expect(rank).to eq(Metasploit::Cache::Module::Rank::NUMBER_BY_NAME['Normal'])
      end
    end
  end
end