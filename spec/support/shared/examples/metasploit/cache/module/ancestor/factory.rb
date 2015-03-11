RSpec.shared_examples_for 'Metasploit::Cache::Module::Ancestor factory' do
  it { is_expected.to be_valid }

  it_should_behave_like 'Metasploit::Cache::Module::Ancestor factory loading'

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
end