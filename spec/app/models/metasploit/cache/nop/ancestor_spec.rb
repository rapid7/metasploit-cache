RSpec.describe Metasploit::Cache::Nop::Ancestor do
  it_should_behave_like 'Metasploit::Cache::Module::Ancestor.restrict',
                        module_type: 'nop',
                        module_type_directory: 'nops'
  it_should_behave_like 'Metasploit::Concern.run'

  context 'associations' do
    it { is_expected.to have_one(:nop_class).class_name('Metasploit::Cache::Nop::Class').with_foreign_key(:ancestor_id) }
    it { is_expected.to belong_to(:parent_path).class_name('Metasploit::Cache::Module::Path') }
  end

  context 'factories' do
    context 'metasploit_cache_nop_ancestor' do
      subject(:metasploit_cache_nop_ancestor) {
        FactoryGirl.build(:metasploit_cache_nop_ancestor)
      }

      it_should_behave_like 'Metasploit::Cache::Module::Ancestor factory' do
        let(:module_ancestor) {
          metasploit_cache_nop_ancestor
        }
      end
    end
  end
end