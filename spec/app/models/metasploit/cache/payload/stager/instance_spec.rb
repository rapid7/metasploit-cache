RSpec.describe Metasploit::Cache::Payload::Stager::Instance do
  it_should_behave_like 'Metasploit::Concern.run'

  context 'database' do
    context 'columns' do
      it { is_expected.to have_db_column(:description).of_type(:text).with_options(null: false) }
      it { is_expected.to have_db_column(:handler_type_alias).of_type(:string).with_options(null: true) }
    end
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :description }
    it { is_expected.not_to validate_presence_of :handler_type_alias }
  end
end