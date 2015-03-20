RSpec.describe Metasploit::Cache::Actionable::Action do
  context 'associations' do
    it { is_expected.to belong_to(:actionable).inverse_of(:actions) }
  end

  context 'database' do
    it { is_expected.to have_db_column(:actionable_id).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:actionable_type).of_type(:string).with_options(null: false) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :actionable }
  end
end