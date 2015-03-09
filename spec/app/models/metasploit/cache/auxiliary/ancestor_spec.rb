RSpec.describe Metasploit::Cache::Auxiliary::Ancestor do
  it_should_behave_like 'Metasploit::Cache::Module::Ancestor.restrict', module_type: 'auxiliary', module_type_directory: 'auxiliary'
  it_should_behave_like 'Metasploit::Concern.run'

  context 'associations' do
    it { is_expected.to have_one(:auxiliary_class).class_name('Metasploit::Cache::Auxiliary::Class').with_foreign_key(:ancestor_id) }
    it { is_expected.to belong_to(:parent_path).class_name('Metasploit::Cache::Module::Path') }
  end

  context 'factories' do
    context 'metasploit_cache_auxiliary_ancestor' do
      subject(:metasploit_cache_auxiliary_ancestor) {
        FactoryGirl.build(:metasploit_cache_auxiliary_ancestor)
      }

      it { is_expected.to be_valid }

      context 'contents' do
        include_context 'Metasploit::Cache::Module::Ancestor factory contents'

        let(:module_ancestor) do
          metasploit_cache_auxiliary_ancestor
        end

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
  end
end