RSpec.describe Metasploit::Cache::Payload::Stager::Instance do
  it_should_behave_like 'Metasploit::Concern.run'

  context 'associations' do
    it { is_expected.to have_many(:architectures).class_name('Metasploit::Cache::Architecture') }
    it { is_expected.to have_many(:architecturable_architectures).autosave(true).class_name('Metasploit::Cache::Architecturable::Architecture').dependent(:destroy).inverse_of(:architecturable) }
    it { is_expected.to have_many(:contributions).autosave(true).class_name('Metasploit::Cache::Contribution').dependent(:destroy).inverse_of(:contributable) }
    it { is_expected.to belong_to(:handler).class_name('Metasploit::Cache::Payload::Handler').inverse_of(:payload_stager_instances) }
    it { is_expected.to have_many(:licensable_licenses).autosave(true).class_name('Metasploit::Cache::Licensable::License')}
    it { is_expected.to have_many(:licenses).class_name('Metasploit::Cache::License')}
    it { is_expected.to have_many(:payload_staged_classes).class_name('Metasploit::Cache::Payload::Staged::Class').dependent(:destroy).inverse_of(:payload_stager_instance) }
    it { is_expected.to belong_to(:payload_stager_class).class_name('Metasploit::Cache::Payload::Stager::Class').inverse_of(:payload_stager_instance) }
    it { is_expected.to have_many(:platforms).class_name('Metasploit::Cache::Platform') }
    it { is_expected.to have_many(:platformable_platforms).class_name('Metasploit::Cache::Platformable::Platform').inverse_of(:platformable) }
  end

  context 'database' do
    context 'columns' do
      it { is_expected.to have_db_column(:description).of_type(:text).with_options(null: false) }
      it { is_expected.to have_db_column(:handler_id).of_type(:integer).with_options(null: false) }
      it { is_expected.to have_db_column(:handler_type_alias).of_type(:string).with_options(null: true) }
      it { is_expected.to have_db_column(:name).of_type(:string).with_options(null: false) }
      it { is_expected.to have_db_column(:payload_stager_class_id).of_type(:integer).with_options(null: false) }
      it { is_expected.to have_db_column(:privileged).of_type(:boolean).with_options(null: false) }
    end

    context 'indices' do
      it { is_expected.to have_db_index(:handler_id).unique(false) }
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
    it { is_expected.to validate_presence_of :handler }
    it { is_expected.not_to validate_presence_of :handler_type_alias }
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :payload_stager_class }
    it { is_expected.to validate_inclusion_of(:privileged).in_array([false, true]) }

    it_should_behave_like 'validates at least one in association',
                          :architecturable_architectures,
                          factory: :metasploit_cache_payload_stage_instance

    it_should_behave_like 'validates at least one in association',
                          :contributions,
                          factory: :metasploit_cache_payload_stager_instance

    it_should_behave_like 'validates at least one in association',
                          :licensable_licenses,
                          factory: :metasploit_cache_payload_stager_instance

    it_should_behave_like 'validates at least one in association',
                          :platformable_platforms,
                          factory: :metasploit_cache_payload_stager_instance

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