RSpec.describe Metasploit::Cache::Payload::Stager::Ancestor, type: :model do
  it_should_behave_like 'Metasploit::Cache::Payload::Ancestor.restrict',
                        payload_type: 'stager',
                        payload_type_directory: 'stagers'
  it_should_behave_like 'Metasploit::Concern.run'

  context 'associations' do
    it { is_expected.to belong_to(:parent_path).class_name('Metasploit::Cache::Module::Path') }
    it { is_expected.to have_one(:stager_payload_class).class_name('Metasploit::Cache::Payload::Stager::Class').with_foreign_key(:ancestor_id) }
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