RSpec.describe Metasploit::Cache::Payload::Handler do
  context 'database' do
    context 'columns' do
      it { is_expected.to have_db_column(:handler_type).of_type(:string).with_options(null: false) }
    end

    context 'indices' do
      it { is_expected.to have_db_index(:handler_type).unique(true) }
    end
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :handler_type }
    it { is_expected.to validate_uniqueness_of :handler_type }
  end

  it_should_behave_like 'Metasploit::Concern.run'
end