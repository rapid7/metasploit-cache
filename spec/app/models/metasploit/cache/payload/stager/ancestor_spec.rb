RSpec.describe Metasploit::Cache::Payload::Stager::Ancestor do
  it_should_behave_like 'Metasploit::Cache::Payload::Ancestor.restrict',
                        payload_type: 'stager',
                        payload_type_directory: 'stagers'
  it_should_behave_like 'Metasploit::Concern.run'

  context 'factories' do
    context 'metasploit_cache_payload_stager_ancestor' do
      subject(:metasploit_cache_payload_stager_ancestor) {
        FactoryGirl.build(:metasploit_cache_payload_stager_ancestor)
      }

      it { is_expected.to be_valid }

      context '#payload_type' do
        subject(:payload_type) {
          metasploit_cache_payload_stager_ancestor.payload_type
        }

        it { is_expected.to eq('stager') }
      end
    end
  end
end