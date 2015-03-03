RSpec.describe Metasploit::Cache::Payload::Single::Ancestor do
  it_should_behave_like 'Metasploit::Cache::Payload::Ancestor.restrict',
                        payload_type: 'single',
                        payload_type_directory: 'singles'
  it_should_behave_like 'Metasploit::Concern.run'

  context 'factories' do
    context 'metasploit_cache_payload_single_ancestor' do
      subject(:metasploit_cache_payload_single_ancestor) {
        FactoryGirl.build(:metasploit_cache_payload_single_ancestor)
      }

      it { is_expected.to be_valid }

      context '#payload_type' do
        subject(:payload_type) {
          metasploit_cache_payload_single_ancestor.payload_type
        }

        it { is_expected.to eq('single') }
      end
    end
  end
end