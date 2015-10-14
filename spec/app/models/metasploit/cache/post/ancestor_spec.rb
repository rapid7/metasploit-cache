RSpec.describe Metasploit::Cache::Post::Ancestor, type: :model do
  it_should_behave_like 'Metasploit::Cache::Module::Ancestor.restrict',
                        module_type: 'post',
                        module_type_directory: 'post'
  it_should_behave_like 'Metasploit::Concern.run'

  context 'associations' do
    it { is_expected.to belong_to(:parent_path).class_name('Metasploit::Cache::Module::Path') }
    it { is_expected.to have_one(:post_class).class_name('Metasploit::Cache::Post::Class').with_foreign_key(:ancestor_id) }
  end

  context 'factories' do
    context 'metasploit_cache_post_ancestor' do
      subject(:metasploit_cache_post_ancestor) {
        FactoryGirl.build(:metasploit_cache_post_ancestor)
      }

      it_should_behave_like 'Metasploit::Cache::Module::Ancestor factory',
                            persister_class: Metasploit::Cache::Module::Ancestor::Persister do
        let(:module_ancestor) {
          metasploit_cache_post_ancestor
        }
      end
    end
  end
end