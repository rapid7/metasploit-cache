RSpec.describe Metasploit::Cache::Architecture::Ephemeral do
  context 'by_abbreviation' do
    subject(:by_abbreviation) {
      described_class.by_abbreviation(existing_abbreviation_set: existing_abbreviation_set)
    }

    let(:existing_abbreviation_set) {
      Set.new
    }

    it 'calls Metasploit:Cache::Ephemeral::AttributeSet.existing_by_attribute_value' do
      expect(Metasploit::Cache::Ephemeral::AttributeSet).to receive(:existing_by_attribute_value).with(
                                                                attribute: :abbreviation,
                                                                scope: Metasploit::Cache::Architecture,
                                                                value_set: existing_abbreviation_set
                                                            )

      by_abbreviation
    end
  end
end