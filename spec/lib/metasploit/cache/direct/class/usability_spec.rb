RSpec.describe Metasploit::Cache::Direct::Class::Usability do
  context 'is_usable' do
    subject(:is_usable) {
      subclass.is_usable
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

    it { is_expected.to eq(true) }
  end
end