RSpec.describe Metasploit::Cache::Architecturable::Architecture do
  context 'associations' do
    it { is_expected.to belong_to(:architecture).class_name('Metasploit::Cache::Architecture').inverse_of(:architecturable_architectures) }
    it { is_expected.to belong_to(:architecturable) }
  end

  context 'database' do
    context 'columns' do
      it { is_expected.to have_db_column(:architecturable_id).of_type(:integer).with_options(null: false) }
      it { is_expected.to have_db_column(:architecturable_type).of_type(:string).with_options(null: false) }
      it { is_expected.to have_db_column(:architecture_id).of_type(:integer).with_options(null: false) }
    end

    context 'indices' do
      it { is_expected.to have_db_index([:architecturable_type, :architecturable_id]).unique(false) }
      it { is_expected.to have_db_index([:architecturable_type, :architecturable_id, :architecture_id]).unique(true) }
      it { is_expected.to have_db_index(:architecture_id).unique(false) }
    end
  end

  context 'factories' do
    context 'metasploit_cache_architecturable_architecture' do
      subject(:metasploit_cache_architecturable_architecture) {
        FactoryGirl.build(:metasploit_cache_architecturable_architecture)
      }

      it { is_expected.not_to be_valid }

      it 'has nil #architecturable' do
        expect(metasploit_cache_architecturable_architecture.architecturable).to be_nil
      end
    end

    context 'metasploit_cache_encoder_architecture' do
      subject(:metasploit_cache_encoder_architecture) {
        FactoryGirl.build(:metasploit_cache_encoder_architecture)
      }

      it { is_expected.to be_valid }
    end

    context 'metasploit_cache_exploit_target_architecture' do
      subject(:metasploit_cache_exploit_target_architecture) {
        FactoryGirl.build(:metasploit_cache_exploit_target_architecture)
      }

      it { is_expected.to be_valid }
    end

    context 'metasploit_cache_nop_architecture' do
      subject(:metasploit_cache_nop_architecture) {
        FactoryGirl.build(:metasploit_cache_nop_architecture)
      }

      it { is_expected.to be_valid }
    end

    context 'metasploit_cache_payload_single_architecture' do
      subject(:metasploit_cache_payload_single_architecture) {
        FactoryGirl.build(:metasploit_cache_payload_single_architecture)
      }

      it { is_expected.to be_valid }
    end

    context 'metasploit_cache_payload_stage_architecture' do
      subject(:metasploit_cache_payload_stage_architecture) {
        FactoryGirl.build(:metasploit_cache_payload_stage_architecture)
      }

      it { is_expected.to be_valid }
    end

    context 'metasploit_cache_payload_stager_architecture' do
      subject(:metasploit_cache_payload_stager_architecture) {
        FactoryGirl.build(:metasploit_cache_payload_stager_architecture)
      }

      it { is_expected.to be_valid }
    end

    context 'metasploit_cache_post_architecture' do
      subject(:metasploit_cache_post_architecture) {
        FactoryGirl.build(:metasploit_cache_post_architecture)
      }

      it { is_expected.to be_valid }
    end
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :architecturable }
    it { is_expected.to validate_presence_of :architecture }

    context 'with pre-existing record' do
      let!(:existing_architecturable_architecture) {
        FactoryGirl.create(:metasploit_cache_encoder_architecture)
      }

      it { is_expected.to validate_uniqueness_of(:architecture_id).scoped_to(:architecturable_type, :architecturable_id) }
    end
  end

  it_should_behave_like 'Metasploit::Concern.run'
end