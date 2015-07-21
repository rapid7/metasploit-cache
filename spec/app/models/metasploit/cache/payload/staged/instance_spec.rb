RSpec.describe Metasploit::Cache::Payload::Staged::Instance do
  context 'associations' do
    it { is_expected.to belong_to(:payload_staged_class).class_name('Metasploit::Cache::Payload::Staged::Class').inverse_of(:payload_staged_instance).with_foreign_key(:payload_staged_class_id) }
  end

  context 'database' do
    context 'columns' do
      it { is_expected.to have_db_column(:payload_staged_class_id).of_type(:integer).with_options(null: false) }
    end

    context 'indices' do
      it { is_expected.to have_db_index([:payload_staged_class_id]).unique(true) }
    end
  end

  context 'factories' do
    context 'metasploit_cache_payload_staged_instance' do
      subject(:metasploit_cache_payload_staged_instance) {
        FactoryGirl.build(:metasploit_cache_payload_staged_instance)
      }

      it { is_expected.to be_valid }
    end
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :payload_staged_class }

    context 'with existing record' do
      let!(:existing_payload_staged_instance) {
        FactoryGirl.create(:metasploit_cache_payload_staged_instance)
      }

      it { is_expected.to validate_uniqueness_of :payload_staged_class_id }
    end
  end
end