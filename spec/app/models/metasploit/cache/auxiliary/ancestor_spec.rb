RSpec.describe Metasploit::Cache::Auxiliary::Ancestor, type: :model do
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

      it_should_behave_like 'Metasploit::Cache::Module::Ancestor factory' do
        let(:module_ancestor) {
          metasploit_cache_auxiliary_ancestor
        }
      end
    end
  end
end