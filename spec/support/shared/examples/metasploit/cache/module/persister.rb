RSpec.shared_examples_for 'Metasploit::Cache::Module::Persister' do
  context 'validations' do
    it { is_expected.to validate_presence_of :ephemeral }
    it { is_expected.to validate_presence_of :logger }
  end
end