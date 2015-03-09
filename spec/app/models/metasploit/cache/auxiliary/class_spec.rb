RSpec.describe Metasploit::Cache::Auxiliary::Class do
  it_should_behave_like 'Metasploit::Concern.run'

  context 'associations' do
    it { is_expected.to belong_to(:ancestor).class_name('Metasploit::Cache::Auxiliary::Ancestor') }
    it { is_expected.to belong_to(:rank).class_name('Metasploit::Cache::Module::Rank') }
  end

  context 'factories' do
    context 'metasploit_cache_auxiliary_class' do
      subject(:metasploit_cache_auxiliary_class) {
        FactoryGirl.build(:metasploit_cache_auxiliary_class)
      }

      it { is_expected.to be_valid }
    end
  end
end