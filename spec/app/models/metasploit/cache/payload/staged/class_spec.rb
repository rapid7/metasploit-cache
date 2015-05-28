RSpec.describe Metasploit::Cache::Payload::Staged::Class do
  context 'association' do
    it { is_expected.to belong_to(:payload_stage_instance).class_name('Metasploit::Cache::Payload::Stage::Instance').inverse_of(:payload_staged_classes) }
    it { is_expected.to belong_to(:payload_stager_instance).class_name('Metasploit::Cache::Payload::Stager::Instance').inverse_of(:payload_staged_classes) }
  end

  context 'database' do
    context 'columns' do
      it { is_expected.to have_db_column(:payload_stage_instance_id).of_type(:integer).with_options(null: false) }
      it { is_expected.to have_db_column(:payload_stager_instance_id).of_type(:integer).with_options(null: false) }
    end

    context 'indices' do
      it { is_expected.to have_db_index(:payload_stage_instance_id).unique(false) }
      it { is_expected.to have_db_index(:payload_stager_instance_id).unique(false) }
      it { is_expected.to have_db_index([:payload_stager_instance_id, :payload_stage_instance_id]).unique(true) }
    end
  end

  context 'factories' do
    context 'metasploit_cache_payload_staged_class' do
      subject(:metasploit_cache_payload_staged_class) {
        FactoryGirl.build(:metasploit_cache_payload_staged_class)
      }

      it { is_expected.to be_valid }
    end
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :payload_stage_instance }
    it { is_expected.to validate_presence_of :payload_stager_instance }

    context 'existing record' do
      let!(:existing_payload_staged_class) {
        FactoryGirl.create(:metasploit_cache_payload_staged_class)
      }

      it { is_expected.to validate_uniqueness_of(:payload_stage_instance_id).scoped_to(:payload_stager_instance_id) }
    end
  end
end