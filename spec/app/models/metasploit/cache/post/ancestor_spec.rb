RSpec.describe Metasploit::Cache::Post::Ancestor do
  it_should_behave_like 'Metasploit::Cache::Module::Ancestor.restrict',
                        module_type: 'post',
                        module_type_directory: 'post'
  it_should_behave_like 'Metasploit::Concern.run'

  context 'factories' do
    context 'metasploit_cache_post_ancestor' do
      subject(:metasploit_cache_post_ancestor) {
        FactoryGirl.build(:metasploit_cache_post_ancestor)
      }

      it { is_expected.to be_valid }
    end
  end
end