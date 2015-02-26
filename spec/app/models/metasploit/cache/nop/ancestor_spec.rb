RSpec.describe Metasploit::Cache::Nop::Ancestor do
  it_should_behave_like 'Metasploit::Cache::Module::Ancestor.restrict',
                        module_type: 'nop',
                        module_type_directory: 'nops'
  it_should_behave_like 'Metasploit::Concern.run'

  context 'factories' do
    context 'metasploit_cache_nop_ancestor' do
      subject(:metasploit_cache_nop_ancestor) {
        FactoryGirl.build(:metasploit_cache_nop_ancestor)
      }

      it { is_expected.to be_valid }
    end
  end
end