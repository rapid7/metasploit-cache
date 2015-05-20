RSpec.describe Metasploit::Cache::Platformable::Platform do
  it_should_behave_like 'Metasploit::Concern.run'

  context 'associations' do
    it { is_expected.to belong_to(:platform).class_name('Metasploit::Cache::Platform').inverse_of(:platformable_platforms) }
  end

  context 'database' do
    context 'columns' do
      it { is_expected.to have_db_column(:platform_id).of_type(:integer).with_options(null: false) }
    end

    context 'indices' do
      it { is_expected.to have_db_index(:platform_id) }
    end
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :platform }
  end
end