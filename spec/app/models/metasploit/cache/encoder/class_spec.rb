RSpec.describe Metasploit::Cache::Encoder::Class, type: :model do
  it_should_behave_like 'Metasploit::Concern.run'

  it_should_behave_like 'Metasploit::Cache::Module::Class::Namable'

  it_should_behave_like 'Metasploit::Cache::Module::Descendant',
                        ancestor: {
                            class_name: 'Metasploit::Cache::Encoder::Ancestor',
                            inverse_of: :encoder_class
                        },
                        factory: :full_metasploit_cache_encoder_class

  it_should_behave_like 'Metasploit::Cache::Module::Rankable',
                        rank: {
                            inverse_of: :encoder_classes
                        }

  context 'associations' do
    it { is_expected.to have_one(:encoder_instance).class_name('Metasploit::Cache::Encoder::Instance').dependent(:destroy).inverse_of(:encoder_class) }
  end

  context 'factories' do
    context 'full_metasploit_cache_encoder_class' do
      subject(:full_metasploit_cache_encoder_class) {
        FactoryGirl.build(:full_metasploit_cache_encoder_class)
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
              module_ancestor: full_metasploit_cache_encoder_class.ancestor,
              persister_class: Metasploit::Cache::Module::Ancestor::Persister
          )
        }

        #
        # Callbacks
        #

        before(:each) do
          # To prove Direct::Class::Load is set rank
          full_metasploit_cache_encoder_class.rank = nil
        end

        context 'Metasploit::Cache::Module::Ancestor::Load' do
          subject {
            module_ancestor_load
          }

          it { is_expected.to be_valid }
        end

        context 'Metasploit::Cache::Direct::Class::Load' do
          subject(:direct_class_load) {
            Metasploit::Cache::Direct::Class::Load.new(
                direct_class: full_metasploit_cache_encoder_class,
                logger: logger,
                metasploit_module: module_ancestor_load.metasploit_module
            )
          }

          before(:each) do
            expect(module_ancestor_load).to be_valid
          end

          it { is_expected.to be_valid }

          specify {
            expect {
              direct_class_load.valid?
            }.to change(described_class, :count).from(0).to(1)
          }
        end
      end
    end

    context 'metasploit_cache_encoder_class' do
      subject(:metasploit_cache_encoder_class) {
        FactoryGirl.build(:metasploit_cache_encoder_class)
      }

      it { is_expected.not_to be_valid }

      context 'Metasploit::Cache::Encoder::Class#name' do
        subject(:name) {
          metasploit_cache_encoder_class.name
        }

        it { is_expected.to be_nil }
      end
    end
  end
end