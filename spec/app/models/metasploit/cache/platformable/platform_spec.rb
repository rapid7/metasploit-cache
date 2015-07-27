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
    context 'metasploit_cache_platformable_platform' do
      subject(:metasploit_cache_platformable_platform) {
        FactoryGirl.build(:metasploit_cache_platformable_platform)
      }

      it { is_expected.not_to be_valid }

      it 'has nil #platformable' do
        expect(metasploit_cache_platformable_platform.platformable).to be_nil
      end
    end
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :platform }
    it { is_expected.to validate_presence_of :platformable }

    context 'with pre-existing record' do
      let!(:existing_platformable_platform) {
        FactoryGirl.create(
            :metasploit_cache_platformable_platform,
            platformable: FactoryGirl.build(:metasploit_cache_encoder_instance)
        )
      }

      it { is_expected.to validate_uniqueness_of(:platform_id).scoped_to(:platformable_type, :platformable_id) }
    end
  end
end