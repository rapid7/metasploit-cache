RSpec.describe Metasploit::Cache::Payload::Stage::Ancestor do
  it_should_behave_like 'Metasploit::Cache::Payload::Ancestor.restrict',
                        payload_type: 'stage',
                        payload_type_directory: 'stages'
  it_should_behave_like 'Metasploit::Concern.run'

  context 'associations' do
    it { is_expected.to belong_to(:parent_path).class_name('Metasploit::Cache::Module::Path') }
  end

  context 'factories' do
    context 'metasploit_cache_payload_stage_ancestor' do
      subject(:metasploit_cache_payload_stage_ancestor) {
        FactoryGirl.build(:metasploit_cache_payload_stage_ancestor)
      }

      it { is_expected.to be_valid }

      context 'contents' do
        include_context 'Metasploit::Cache::Module::Ancestor factory contents'

        let(:module_ancestor) do
          metasploit_cache_payload_stage_ancestor
        end

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

      context '#payload_type' do
        subject(:payload_type) {
          metasploit_cache_payload_stage_ancestor.payload_type
        }

        it { is_expected.to eq('stage') }
      end
    end
  end
end