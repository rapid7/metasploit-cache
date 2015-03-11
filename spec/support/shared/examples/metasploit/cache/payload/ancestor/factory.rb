RSpec.shared_examples_for 'Metasploit::Cache::Payload::Ancestor factory' do |payload_type:|
  let(:module_ancestor) {
    payload_ancestor
  }

  it { is_expected.to be_valid }

  context 'contents' do
    include_context 'Metasploit::Cache::Module::Ancestor factory contents'

    context 'metasploit_module' do
      include_context 'Metasploit::Cache::Module::Ancestor factory contents metasploit_module'

      it { should be_a Module }
      it { should_not be_a Class }

      it 'should define #initalize that takes an option hash' do
        unbound_method = metasploit_module.instance_method(:initialize)

        expect(unbound_method.parameters.length).to eq(1)
        expect(unbound_method.parameters[0][0]).to eq(:opt)
      end
    end
  end

  context 'loading' do
    include_context 'Metasploit::Cache::Module::Ancestor::Spec::Unload.unload'

    context 'Metasploit::Cache::Module::Ancestor::Load' do
      subject(:module_ancestor_load) {
        Metasploit::Cache::Module::Ancestor::Load.new(
            logger: logger,
            maximum_version: 4,
            module_ancestor: module_ancestor
        )
      }

      let(:logger) {
        ActiveSupport::TaggedLogging.new(
            Logger.new(string_io)
        )
      }

      let(:string_io) {
        StringIO.new
      }

      it { is_expected.to be_valid }

      specify {
        expect {
          module_ancestor_load.valid?
        }.to change(described_class, :count).from(0).to(1)
      }
    end
  end

  context '#payload_type' do
    subject(:actual_payload_type) {
      payload_ancestor.payload_type
    }

    it { is_expected.to eq(payload_type) }
  end
end