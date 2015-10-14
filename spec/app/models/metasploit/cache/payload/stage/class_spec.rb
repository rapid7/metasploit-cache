RSpec.describe Metasploit::Cache::Payload::Stage::Class, type: :model do
  it_should_behave_like 'Metasploit::Concern.run'

  it_should_behave_like 'Metasploit::Cache::Module::Descendant',
                        ancestor: {
                            class_name: 'Metasploit::Cache::Payload::Stage::Ancestor',
                            inverse_of: :stage_payload_class
                        },
                        factory: :metasploit_cache_payload_stage_class

  it_should_behave_like 'Metasploit::Cache::Module::Rankable',
                        rank: {
                            inverse_of: :stage_payload_classes
                        }

  context 'associations' do
    it { is_expected.to have_one(:payload_stage_instance).class_name('Metasploit::Cache::Payload::Stage::Instance').dependent(:destroy).inverse_of(:payload_stage_class).with_foreign_key(:payload_stage_class_id) }
  end

  context 'factories' do
    context 'metasploit_cache_payload_stage_class' do
      subject(:metasploit_cache_payload_stage_class) {
        FactoryGirl.build(:metasploit_cache_payload_stage_class)
      }

      it { is_expected.to be_valid }

      context 'loading' do
        include_context 'ActiveSupport::TaggedLogging'
        include_context 'Metasploit::Cache::Spec::Unload.unload'

        #
        # lets
        #

        let(:module_ancestor_load) {
          Metasploit::Cache::Module::Ancestor::Load.new(
              logger: logger,
              maximum_version: 4,
              module_ancestor: metasploit_cache_payload_stage_class.ancestor,
              persister_class: Metasploit::Cache::Module::Ancestor::Persister
          )
        }

        #
        # Callbacks
        #

        before(:each) do
          # To prove Payload::Unhandled::Class::Load is setting rank
          metasploit_cache_payload_stage_class.rank = nil
        end

        context 'Metasploit::Cache::Module::Ancestor::Load' do
          subject {
            module_ancestor_load
          }

          it { is_expected.to be_valid }
        end

        context 'Metasploit::Cache::Payload::Unhandled::Class::Load' do
          subject(:payload_unhandled_class_load) {
            Metasploit::Cache::Payload::Unhandled::Class::Load.new(
                logger: logger,
                metasploit_module: module_ancestor_load.metasploit_module,
                payload_unhandled_class: metasploit_cache_payload_stage_class,
                payload_superclass: Metasploit::Cache::Direct::Class::Superclass
            )
          }

          before(:each) do
            expect(module_ancestor_load).to be_valid
          end

          it { is_expected.to be_valid }

          specify {
            expect {
              payload_unhandled_class_load.valid?
            }.to change(described_class, :count).from(0).to(1)
          }
        end
      end
    end
  end
end