RSpec.describe Metasploit::Cache::Payload::Stager::Ancestor, type: :model do
  it_should_behave_like 'Metasploit::Cache::Payload::Ancestor.restrict',
                        payload_type: 'stager',
                        payload_type_directory: 'stagers'
  it_should_behave_like 'Metasploit::Concern.run'

  context 'associations' do
    it { is_expected.to have_one(:handler).autosave(true).class_name('Metasploit::Cache::Payload::Stager::Ancestor::Handler').dependent(:destroy).inverse_of(:payload_stager_ancestor).with_foreign_key(:payload_stager_ancestor_id) }
    it { is_expected.to belong_to(:parent_path).class_name('Metasploit::Cache::Module::Path') }
    it { is_expected.to have_one(:stager_payload_class).class_name('Metasploit::Cache::Payload::Stager::Class').with_foreign_key(:ancestor_id) }
  end

  context 'factories' do
    context 'metasploit_cache_payload_stager_ancestor' do
      subject(:metasploit_cache_payload_stager_ancestor) {
        FactoryGirl.build(:metasploit_cache_payload_stager_ancestor)
      }

      it_should_behave_like 'Metasploit::Cache::Payload::Ancestor factory',
                            payload_type: 'stager',
                            persister_class: Metasploit::Cache::Module::Ancestor::Persister do
        let(:payload_ancestor) {
          metasploit_cache_payload_stager_ancestor
        }
      end

      context '#handler' do
        subject(:handler) {
          metasploit_cache_payload_stager_ancestor.handler
        }

        it { is_expected.to be_nil }
      end
    end

    context 'full_metasploit_cache_payload_stager_ancestor' do
      subject(:full_metasploit_cache_payload_stager_ancestor) {
        FactoryGirl.build(:full_metasploit_cache_payload_stager_ancestor)
      }

      it_should_behave_like 'Metasploit::Cache::Payload::Ancestor factory',
                            payload_type: 'stager',
                            persister_class: Metasploit::Cache::Payload::Stager::Ancestor::Persister do
        let(:payload_ancestor) {
          full_metasploit_cache_payload_stager_ancestor
        }
      end

      context '#handler' do
        subject(:handler) {
          full_metasploit_cache_payload_stager_ancestor.handler
        }

        it { is_expected.not_to be_nil }
        it { is_expected.to be_valid }
      end
    end
  end
end