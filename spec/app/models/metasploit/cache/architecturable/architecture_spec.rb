RSpec.describe Metasploit::Cache::Architecturable::Architecture do
  context 'associations' do
    it { is_expected.to belong_to(:architecture).class_name('Metasploit::Cache::Architecture').inverse_of(:architecturable_architectures) }
  end

  context 'database' do
    context 'columns' do
      it { is_expected.to have_db_column(:architecture_id).of_type(:integer).with_options(null: false) }
    end

    context 'indices' do
      it { is_expected.to have_db_index(:architecture_id) }
    end
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :architecture }
  end

  it_should_behave_like 'Metasploit::Concern.run'
end