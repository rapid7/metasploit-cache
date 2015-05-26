RSpec.describe Metasploit::Cache::Author do
  context 'associations' do
    it { is_expected.to have_many(:contributions).class_name('Metasploit::Cache::Contribution').dependent(:destroy).inverse_of(:author) }
    it { should have_many(:email_addresses).class_name('Metasploit::Cache::EmailAddress').through(:module_authors) }
    it { should have_many(:module_authors).class_name('Metasploit::Cache::Module::Author').dependent(:destroy) }
    it { should have_many(:module_instances).class_name('Metasploit::Cache::Module::Instance').through(:module_authors) }
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:name).of_type(:string).with_options(:null => false) }
    end

    context 'indices' do
      it { should have_db_index(:name).unique(true) }
    end
  end

  context 'factories' do
    context :metasploit_cache_author do
      subject(:metasploit_cache_author) do
        FactoryGirl.build(:metasploit_cache_author)
      end

      it { should be_valid }
    end
  end

  context 'mass assignment security' do
    it { should allow_mass_assignment_of(:name) }
  end

  context 'search' do
    let(:base_class) {
      Metasploit::Cache::Author
    }

    context 'attributes' do
      it_should_behave_like 'search_attribute', :name, :type => :string
    end
  end

  context 'validations' do
    it { should validate_presence_of :name }
    it { should validate_uniqueness_of :name }
  end
end