RSpec.describe Metasploit::Cache::Payload::Handler do
  context 'associations' do
    it { is_expected.to have_many(:payload_single_instances).class_name('Metasploit::Cache::Payload::Single::Instance').dependent(:destroy).inverse_of(:handler) }
    it { is_expected.to have_many(:payload_stager_instances).class_name('Metasploit::Cache::Payload::Stager::Instance').dependent(:destroy).inverse_of(:handler) }
  end

  context 'database' do
    context 'columns' do
      it { is_expected.to have_db_column(:general_handler_type).of_type(:string).with_options(null: false) }
      it { is_expected.to have_db_column(:handler_type).of_type(:string).with_options(null: false) }
    end

    context 'indices' do
      it { is_expected.to have_db_index(:handler_type).unique(true) }
    end
  end

  context 'factories' do
    context 'metasploit_cache_payload_handler' do
      subject(:metasploit_cache_payload_handler) {
        FactoryGirl.build(:metasploit_cache_payload_handler)
      }

      it { is_expected.to be_valid }
    end
  end

  context 'validations' do
    it { is_expected.to validate_inclusion_of(:general_handler_type).in_array(Metasploit::Cache::Payload::Handler::GeneralType::ALL) }
    it { is_expected.to validate_presence_of :handler_type }

    # validate_uniqueness_of needs a pre-existing record of the same class to work correctly when the `null: false`
    # constraints exist for other fields.
    context 'with existing record' do
      let!(:existing_payload_handler) {
        FactoryGirl.create(
            :metasploit_cache_payload_handler
        )
      }

      it { is_expected.to validate_uniqueness_of :handler_type }
    end
  end

  it_should_behave_like 'Metasploit::Concern.run'
end