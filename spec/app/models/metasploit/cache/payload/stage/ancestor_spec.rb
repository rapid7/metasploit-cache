RSpec.describe Metasploit::Cache::Payload::Stage::Ancestor do
  it_should_behave_like 'Metasploit::Cache::Payload::Ancestor.restrict',
                        payload_type: 'stage',
                        payload_type_directory: 'stages'
  it_should_behave_like 'Metasploit::Concern.run'

  context 'factories' do
    context 'metasploit_cache_payload_stage_ancestor' do
      subject(:metasploit_cache_payload_stage_ancestor) {
        FactoryGirl.build(:metasploit_cache_payload_stage_ancestor)
      }

      it { is_expected.to be_valid }

      context '#payload_type' do
        subject(:payload_type) {
          metasploit_cache_payload_stage_ancestor.payload_type
        }

        it { is_expected.to eq('stage') }
      end
    end
  end
end