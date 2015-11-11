RSpec.describe Metasploit::Cache::Payload::Stager::Ancestor::Handler, type: :model do
  it_should_behave_like 'Metasploit::Concern.run'

  context 'associations' do
    it { is_expected.to belong_to(:payload_stager_ancestor).class_name('Metasploit::Cache::Payload::Stager::Ancestor').inverse_of(:handler).with_foreign_key(:payload_stager_ancestor_id) }
  end

  context 'database' do
    context 'columns' do
      it { is_expected.to have_db_column(:payload_stager_ancestor_id).of_type(:integer).with_options(null: false) }
      it { is_expected.to have_db_column(:type_alias).of_type(:string).with_options(null: false) }
    end

    context 'indices' do
      it { is_expected.to have_db_index(:payload_stager_ancestor_id).unique(true) }
    end
  end

  context 'factories' do
    context 'metasploit_cache_payload_stager_ancestor_handler' do
      subject(:metasploit_cache_payload_stager_ancestor_handler) {
        FactoryGirl.build(:metasploit_cache_payload_stager_ancestor_handler)
      }

      it { is_expected.to be_valid }
    end
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :payload_stager_ancestor }
    it { is_expected.to validate_presence_of :type_alias }

    context 'with existing record' do
      let!(:existing_payload_stager_ancestor_handler) {
        FactoryGirl.create(:metasploit_cache_payload_stager_ancestor_handler)
      }

      it { is_expected.to validate_uniqueness_of :payload_stager_ancestor_id }
    end
  end
end