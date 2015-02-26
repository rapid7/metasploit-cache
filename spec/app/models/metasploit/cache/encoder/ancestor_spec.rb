RSpec.describe Metasploit::Cache::Auxiliary::Ancestor do
  it_should_behave_like 'Metasploit::Cache::Module::Ancestor.restrict', module_type: 'auxiliary', module_type_directory: 'auxiliary'
  it_should_behave_like 'Metasploit::Concern.run'

  context 'factories' do
    context 'metasploit_cache_encoder_ancestor' do
      subject(:metasploit_cache_encoder_ancestor) {
        FactoryGirl.build(:metasploit_cache_encoder_ancestor)
      }

      it { is_expected.to be_valid }
    end
  end
end