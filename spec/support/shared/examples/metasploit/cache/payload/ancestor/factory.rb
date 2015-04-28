RSpec.shared_examples_for 'Metasploit::Cache::Payload::Ancestor factory' do |payload_type:|
  let(:module_ancestor) {
    payload_ancestor
  }

  it { is_expected.to be_valid }

  it_should_behave_like 'Metasploit::Cache::Module::Ancestor factory loading'

  context 'contents' do
    include_context 'Metasploit::Cache::Module::Ancestor factory contents'

    context 'metasploit_module' do
      include_context 'Metasploit::Cache::Module::Ancestor factory contents metasploit_module'

      it { should be_a Module }
      it { should_not be_a Class }
    end
  end

  context '#payload_type' do
    subject(:actual_payload_type) {
      payload_ancestor.payload_type
    }

    it { is_expected.to eq(payload_type) }
  end
end