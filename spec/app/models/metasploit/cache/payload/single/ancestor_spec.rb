RSpec.describe Metasploit::Cache::Payload::Single::Ancestor do
  it_should_behave_like 'Metasploit::Cache::Payload::Ancestor.restrict',
                        payload_type: 'single',
                        payload_type_directory: 'singles'
  it_should_behave_like 'Metasploit::Concern.run'

  context 'associations' do
    it { is_expected.to belong_to(:parent_path).class_name('Metasploit::Cache::Module::Path') }
    it { is_expected.to have_one(:single_payload_class).class_name('Metasploit::Cache::Payload::Single::Class').with_foreign_key(:ancestor_id) }
  end

  context 'factories' do
    context 'metasploit_cache_payload_single_ancestor' do
      subject(:metasploit_cache_payload_single_ancestor) {
        FactoryGirl.build(:metasploit_cache_payload_single_ancestor)
      }

      it_should_behave_like 'Metasploit::Cache::Payload::Ancestor factory',
                            payload_type: 'single' do
        let(:payload_ancestor) {
          metasploit_cache_payload_single_ancestor
        }
      end
    end
  end
end