RSpec.shared_examples_for 'Metasploit::Cache::Module::Ancestor factory' do
  it { is_expected.to be_valid }

  context 'contents' do
    include_context 'Metasploit::Cache::Module::Ancestor factory contents'

    context 'metasploit_module' do
      include_context 'Metasploit::Cache::Module::Ancestor factory contents metasploit_module'

      it { should be_a Class }

      context '#initialize' do
        subject(:instance) do
          metasploit_module.new(attributes)
        end

        context 'with :framework' do
          let(:attributes) do
            {
                framework: framework
            }
          end

          let(:framework) do
            double('Msf::Framework')
          end

          it 'should set #framework' do
            expect(instance.framework).to eq(framework)
          end
        end
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
end