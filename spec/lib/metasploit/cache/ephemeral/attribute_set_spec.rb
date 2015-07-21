RSpec.describe Metasploit::Cache::Ephemeral::AttributeSet do
  context 'added' do
    subject(:added) {
      described_class.added(
          destination: destination,
          source: source
      )
    }

    let(:destination) {
      Set.new [:common, :destination]
    }

    let(:source) {
      Set.new [:added, :common]
    }

    it 'substracts :destination from :source' do
      expect(added).to eq(Set.new [:added])
    end
  end

  context 'removed' do
    subject(:removed) {
      described_class.removed(
          destination: destination,
          source: source
      )
    }

    let(:destination) {
      Set.new [:common, :removed]
    }

    let(:source) {
      Set.new [:common]
    }

    it 'substracts :source from :destination' do
      expect(removed).to eq(Set.new [:removed])
    end
  end
end