RSpec.describe Metasploit::Cache::Contribution do
  it_should_behave_like 'Metasploit::Concern.run'

  context 'associations' do
    it { is_expected.to belong_to(:email_address).class_name('Metasploit::Cache::EmailAddress').inverse_of(:contributions) }
    it { is_expected.to belong_to(:author).class_name('Metasploit::Cache::Author').inverse_of(:contributions) }
  end

  context 'database' do
    context 'columns' do
      it { is_expected.to have_db_column(:author_id).of_type(:integer).with_options(null: false) }
      it { is_expected.to have_db_column(:email_address_id).of_type(:integer).with_options(null: false) }
    end

    context 'indices' do
      it { is_expected.to have_db_index(:author_id).unique(false) }
      it { is_expected.to have_db_index(:email_address_id).unique(false) }
    end
  end
end