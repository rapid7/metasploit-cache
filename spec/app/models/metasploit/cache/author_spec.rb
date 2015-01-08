RSpec.describe Metasploit::Cache::Author do
  it_should_behave_like 'Metasploit::Cache::Author',
                        namespace_name: 'Metasploit::Cache'

  context 'associations' do
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

  context 'validations' do
    it { should validate_uniqueness_of :name }
  end
end