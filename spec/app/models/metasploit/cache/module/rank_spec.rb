RSpec.describe Metasploit::Cache::Module::Rank do
  subject(:rank) do
    FactoryGirl.generate :metasploit_cache_module_rank
  end

  it_should_behave_like 'Metasploit::Cache::Module::Rank',
                        namespace_name: 'Metasploit::Cache' do
    # have to delete the seeds because Metasploit::Cache::Module::Rank validations specs can't handle uniqueness
    # constraint supplied by database model.
    before(:each) do
      Metasploit::Cache::Module::Rank.destroy_all
    end
  end

  context 'associations' do
    it { should have_many(:module_classes).class_name('Metasploit::Cache::Module::Class').dependent(:destroy) }
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:name).of_type(:string).with_options(:null => false) }
      it { should have_db_column(:number).of_type(:integer).with_options(:null => false) }
    end

    context 'indices' do
      it { should have_db_index(:name).unique(true) }
      it { should have_db_index(:number).unique(true) }
    end
  end

  context 'validations' do
    it { should validate_uniqueness_of(:name) }
    it { should validate_uniqueness_of(:number) }
  end

  # Not in 'Metasploit::Cache::Module::Rank' shared example since sequence should not be overridden in namespaces.
  context 'sequences' do
    context 'metasploit_cache_module_rank_name' do
      subject(:metasploit_cache_module_rank_name) do
        FactoryGirl.generate :metasploit_cache_module_rank_name
      end

      it 'should be key in Metasploit::Cache::Module::Rank::NUMBER_BY_NAME' do
        expect(Metasploit::Cache::Module::Rank::NUMBER_BY_NAME).to have_key(metasploit_cache_module_rank_name)
      end
    end

    context 'metasploit_cache_module_rank_number' do
      subject(:metasploit_cache_module_rank_number) do
        FactoryGirl.generate :metasploit_cache_module_rank_number
      end

      it 'should be value in Metasploit::Cache::Module::Rank::NUMBER_BY_NAME' do
        expect(Metasploit::Cache::Module::Rank::NUMBER_BY_NAME).to have_value(metasploit_cache_module_rank_number)
      end
    end
  end
end