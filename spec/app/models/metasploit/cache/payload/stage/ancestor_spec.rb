RSpec.describe Metasploit::Cache::Payload::Stage::Ancestor, type: :model do
  it_should_behave_like 'Metasploit::Cache::Payload::Ancestor.restrict',
                        payload_type: 'stage',
                        payload_type_directory: 'stages'
  it_should_behave_like 'Metasploit::Concern.run'

  context 'associations' do
    it { is_expected.to belong_to(:parent_path).class_name('Metasploit::Cache::Module::Path') }
    it { is_expected.to have_one(:stage_payload_class).class_name('Metasploit::Cache::Payload::Stage::Class').with_foreign_key(:ancestor_id) }
  end

  context 'factories' do
    context 'metasploit_cache_payload_stage_ancestor' do
      subject(:metasploit_cache_payload_stage_ancestor) {
        FactoryGirl.build(:metasploit_cache_payload_stage_ancestor)
      }

      it_should_behave_like 'Metasploit::Cache::Payload::Ancestor factory',
                            payload_type: 'stage',
                            persister_class: Metasploit::Cache::Module::Ancestor::Persister do
        let(:payload_ancestor) {
          metasploit_cache_payload_stage_ancestor
        }
      end
    end
  end
end