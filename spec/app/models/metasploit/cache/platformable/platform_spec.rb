RSpec.describe Metasploit::Cache::Platformable::Platform do
  it_should_behave_like 'Metasploit::Concern.run'

  context 'associations' do
    it { is_expected.to belong_to(:platform).class_name('Metasploit::Cache::Platform').inverse_of(:platformable_platforms) }
    it { is_expected.to belong_to(:platformable) }
  end

  context 'database' do
    context 'columns' do
      it { is_expected.to have_db_column(:platform_id).of_type(:integer).with_options(null: false) }
      it { is_expected.to have_db_column(:platformable_id).of_type(:integer).with_options(null: false) }
      it { is_expected.to have_db_column(:platformable_type).of_type(:string).with_options(null: false) }
    end

    context 'indices' do
      it { is_expected.to have_db_index(:platform_id).unique(false) }
      it { is_expected.to have_db_index([:platformable_type, :platformable_id]).unique(false) }
      it { is_expected.to have_db_index([:platformable_type, :platformable_id, :platform_id]).unique(true) }
    end
  end

  context 'factories' do
    context 'metasploit_cache_encoder_platform' do
      subject(:metasploit_cache_encoder_platform) {
        FactoryGirl.build(:metasploit_cache_encoder_platform)
      }

      it { is_expected.to be_valid }
    end

    context 'metasploit_cache_exploit_target_platform' do
      subject(:metasploit_cache_exploit_target_platform) {
        FactoryGirl.build(:metasploit_cache_exploit_target_platform)
      }

      it { is_expected.to be_valid }
    end

    context 'metasploit_cache_nop_platform' do
      subject(:metasploit_cache_nop_platform) {
        FactoryGirl.build(:metasploit_cache_nop_platform)
      }

      it { is_expected.to be_valid }
    end

    context 'metasploit_cache_payload_single_platform' do
      subject(:metasploit_cache_payload_single_platform) {
        FactoryGirl.build(:metasploit_cache_payload_single_platform)
      }

      it { is_expected.to be_valid }
    end

    context 'metasploit_cache_payload_stage_platform' do
      subject(:metasploit_cache_payload_stage_platform) {
        FactoryGirl.build(:metasploit_cache_payload_stage_platform)
      }

      it { is_expected.to be_valid }
    end

    context 'metasploit_cache_payload_stager_platform' do
      subject(:metasploit_cache_payload_stager_platform) {
        FactoryGirl.build(:metasploit_cache_payload_stager_platform)
      }

      it { is_expected.to be_valid }
    end

    context 'metasploit_cache_post_platform' do
      subject(:metasploit_cache_post_platform) {
        FactoryGirl.build(:metasploit_cache_post_platform)
      }

      it { is_expected.to be_valid }
    end
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :platform }
    it { is_expected.to validate_presence_of :platformable }

    context 'with pre-existing record' do
      let!(:existing_platformable_platform) {
        FactoryGirl.create(:metasploit_cache_encoder_platform)
      }

      it { is_expected.to validate_uniqueness_of(:platform_id).scoped_to(:platformable_type, :platformable_id) }
    end
  end
end