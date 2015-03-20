RSpec.describe Metasploit::Cache::Auxiliary::Instance do
  context 'associations' do
    it { is_expected.to belong_to(:auxiliary_class).class_name('Metasploit::Cache::Auxiliary::Class').foreign_key(:auxiliary_class_id).inverse_of(:auxiliary_instance) }
  end

  context 'database' do
    it { is_expected.to have_db_column(:auxiliary_class_id).of_type(:integer).with_options(null: false) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:auxiliary_class) }
  end
end