RSpec.describe Metasploit::Cache::Payload::Stager::Instance do
  it_should_behave_like 'Metasploit::Concern.run'

  context 'database' do
    context 'columns' do
      it { is_expected.to have_db_column(:description).of_type(:text).with_options(null: false) }
    end
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :description }
  end
end