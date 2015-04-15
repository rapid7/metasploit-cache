RSpec.describe Metasploit::Cache::Payload::Stager::Instance do
  it_should_behave_like 'Metasploit::Concern.run'

  context 'database' do
    context 'columns' do
      it { is_expected.to have_db_column(:description).of_type(:text).with_options(null: false) }
      it { is_expected.to have_db_column(:handler_type_alias).of_type(:string).with_options(null: true) }
      it { is_expected.to have_db_column(:name).of_type(:string).with_options(null: false) }
      it { is_expected.to have_db_column(:payload_stager_class_id).of_type(:integer).with_options(null: false) }
    end

    context 'indices' do
      it { is_expected.to have_db_index(:payload_stager_class_id).unique(true) }
    end
  end

  context 'factories' do
    context 'metasploit_cache_payload_stager_instance' do
      subject(:metasploit_cache_payload_stager_instance) {
        FactoryGirl.build(:metasploit_cache_payload_stager_instance)
      }

      it { is_expected.to be_valid }
    end
  end
  
  context 'validations' do
    it { is_expected.to validate_presence_of :description }
    it { is_expected.not_to validate_presence_of :handler_type_alias }
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :payload_stager_class }

    # validate_uniqueness_of needs a pre-existing record of the same class to work correctly when the `null: false`
    # constraints exist for other fields.
    context 'with existing record' do
      let!(:existing_payload_stager_instance) {
        FactoryGirl.create(
            :metasploit_cache_payload_stager_instance
        )
      }

      it { is_expected.to validate_uniqueness_of :payload_stager_class_id }
    end
  end
end