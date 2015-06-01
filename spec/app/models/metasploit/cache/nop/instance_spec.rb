RSpec.describe Metasploit::Cache::Nop::Instance do
  it_should_behave_like 'Metasploit::Concern.run'

  context 'associations' do
    it { is_expected.to have_many(:architectures).class_name('Metasploit::Cache::Architecture') }
    it { is_expected.to have_many(:architecturable_architectures).class_name('Metasploit::Cache::Architecturable::Architecture').dependent(:destroy).inverse_of(:architecturable) }
    it { is_expected.to have_many(:licensable_licenses).class_name('Metasploit::Cache::Licensable::License')}
    it { is_expected.to have_many(:licenses).class_name('Metasploit::Cache::License')}
    it { is_expected.to belong_to(:nop_class).class_name('Metasploit::Cache::Nop::Class').inverse_of(:nop_instance) }
    it { is_expected.to have_many(:platforms).class_name('Metasploit::Cache::Platform') }
    it { is_expected.to have_many(:platformable_platforms).class_name('Metasploit::Cache::Platformable::Platform').inverse_of(:platformable) }
  end

  context 'database' do
    context 'columns' do
      it { is_expected.to have_db_column(:description).of_type(:text).with_options(null: false) }
      it { is_expected.to have_db_column(:name).of_type(:string).with_options(null: false) }
      it { is_expected.to have_db_column(:nop_class_id).of_type(:integer).with_options(null: false) }
    end

    context 'indices' do
      it { is_expected.to have_db_index(:nop_class_id).unique(true) }
    end
  end

  context 'factory' do
    context 'metasploit_cache_nop_instance' do
      subject(:metasploit_cache_nop_instance) {
        FactoryGirl.build(:metasploit_cache_nop_instance)
      }

      it { is_expected.to be_valid }
    end
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :description }
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :nop_class }

    it_should_behave_like 'validates at least one associated',
                          :architecturable_architectures,
                          factory: :metasploit_cache_nop_instance

    it_should_behave_like 'validates at least one in association',
                          :licensable_licenses,
                          factory: :metasploit_cache_nop_instance

    it_should_behave_like 'validates at least one in association',
                          :platformable_platforms,
                          factory: :metasploit_cache_nop_instance

    # validate_uniqueness_of needs a pre-existing record of the same class to work correctly when the `null: false`
    # constraints exist for other fields.
    context 'with existing record' do
      let!(:existing_nop_instance) {
        FactoryGirl.create(
            :metasploit_cache_nop_instance
        )
      }

      it { is_expected.to validate_uniqueness_of :nop_class_id }
    end
  end
end