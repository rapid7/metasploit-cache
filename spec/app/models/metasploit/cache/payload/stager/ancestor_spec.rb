RSpec.describe Metasploit::Cache::Payload::Stager::Ancestor do
  it_should_behave_like 'Metasploit::Cache::Payload::Ancestor.restrict',
                        payload_type: 'stager',
                        payload_type_directory: 'stagers'
  it_should_behave_like 'Metasploit::Concern.run'

  context 'associations' do
    it { is_expected.to belong_to(:parent_path).class_name('Metasploit::Cache::Module::Path') }
  end

  context 'factories' do
    context 'metasploit_cache_payload_stager_ancestor' do
      subject(:metasploit_cache_payload_stager_ancestor) {
        FactoryGirl.build(:metasploit_cache_payload_stager_ancestor)
      }

      it_should_behave_like 'Metasploit::Cache::Payload::Ancestor factory',
                            payload_type: 'stager' do
        let(:payload_ancestor) {
          metasploit_cache_payload_stager_ancestor
        }
      end
    end
  end
end