RSpec.describe Metasploit::Cache::Payload::Staged::Class do
  context 'association' do
    it { is_expected.to belong_to(:payload_stage_instance).class_name('Metasploit::Cache::Payload::Stage::Instance').inverse_of(:payload_staged_classses) }
  end

  context 'database' do
    context 'columns' do
      it { is_expected.to have_db_column(:payload_stage_instance_id).of_type(:integer).with_options(null: false) }
    end

    context 'indices' do
      it { is_expected.to have_db_index(:payload_stage_instance_id).unique(false) }
    end
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :payload_stage_instance }
  end
end