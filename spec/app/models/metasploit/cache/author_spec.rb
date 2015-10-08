RSpec.describe Metasploit::Cache::Author, type: :model do
  context 'associations' do
    it { is_expected.to have_many(:contributions).class_name('Metasploit::Cache::Contribution').dependent(:destroy).inverse_of(:author) }
    it { is_expected.to have_many(:email_addresses).class_name('Metasploit::Cache::EmailAddress').through(:contributions) }
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:name).of_type(:string).with_options(null: false) }
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

  context 'search' do
    let(:base_class) {
      Metasploit::Cache::Author
    }

    context 'attributes' do
      it_should_behave_like 'search_attribute', :name, type: :string
    end
  end

  context 'validations' do
    it { should validate_presence_of :name }
    it { should validate_uniqueness_of :name }
  end
end