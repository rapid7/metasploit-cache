RSpec.describe Metasploit::Cache::Post::Instance do
  it_should_behave_like 'Metasploit::Concern.run'

  context 'database' do
    context 'columns' do
      it { is_expected.to have_many(:contributions).class_name('Metasploit::Cache::Contribution').dependent(:destroy).inverse_of(:contribution) }
      it { is_expected.to have_db_column(:description).of_type(:text).with_options(null: false) }
      it { is_expected.to have_db_column(:disclosed_on).of_type(:date).with_options(null: false) }
      it { is_expected.to have_db_column(:name).of_type(:string).with_options(null: false) }
      it { is_expected.to have_db_column(:post_class_id).of_type(:integer).with_options(null: false) }
      it { is_expected.to have_db_column(:privileged).of_type(:boolean).with_options(null: false) }
    end

    context 'indices' do
      it { is_expected.to have_db_index(:post_class_id).unique(true) }
    end
  end

  context 'associations' do
    it { is_expected.to belong_to(:post_class).class_name('Metasploit::Cache::Post::Class').inverse_of(:post_instance) }
    it { is_expected.to have_many(:licensable_licenses).class_name('Metasploit::Cache::Licensable::License')}
    it { is_expected.to have_many(:licenses).class_name('Metasploit::Cache::License')}
  end

  context 'factories' do
    context 'metasploit_cache_post_instance' do
      subject(:metasploit_cache_post_instance) {
        FactoryGirl.build(:metasploit_cache_post_instance)
      }

      it { is_expected.to be_valid }
    end
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :description }
    it { is_expected.to validate_presence_of :disclosed_on }
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :post_class }
    it { is_expected.to validate_inclusion_of(:privileged).in_array([false, true]) }

    it_should_behave_like 'validates at least one in association',
                          :contributions,
                          factory: :metasploit_cache_post_instance

    it_should_behave_like 'validates at least one in association',
                          :licensable_licenses,
                          factory: :metasploit_cache_post_instance

    # validate_uniqueness_of needs a pre-existing record of the same class to work correctly when the `null: false`
    # constraints exist for other fields.
    context 'with existing record' do
      let!(:existing_post_instance) {
        FactoryGirl.create(
            :metasploit_cache_post_instance
        )
      }

      it { is_expected.to validate_uniqueness_of :post_class_id }
    end
  end
end