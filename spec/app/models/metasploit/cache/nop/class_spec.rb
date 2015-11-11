RSpec.describe Metasploit::Cache::Nop::Class, type: :model do
  it_should_behave_like 'Metasploit::Cache::Module::Class::Namable'

  it_should_behave_like 'Metasploit::Cache::Module::Descendant',
                        ancestor: {
                            class_name: 'Metasploit::Cache::Nop::Ancestor',
                            inverse_of: :nop_class
                        },
                        factory: :full_metasploit_cache_nop_class

  it_should_behave_like 'Metasploit::Cache::Module::Rankable',
                        rank: {
                            inverse_of: :nop_classes
                        }

  it_should_behave_like 'Metasploit::Concern.run'

  context 'associations' do
    it { is_expected.to have_one(:nop_instance).class_name('Metasploit::Cache::Nop::Instance').dependent(:destroy).inverse_of(:nop_class).with_foreign_key(:nop_class_id) }
  end

  context 'factories' do
    context 'full_metasploit_cache_nop_class' do
      subject(:full_metasploit_cache_nop_class) {
        FactoryGirl.build(:full_metasploit_cache_nop_class)
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
              module_ancestor: full_metasploit_cache_nop_class.ancestor,
              persister_class: Metasploit::Cache::Module::Ancestor::Persister
          )
        }

        #
        # Callbacks
        #

        before(:each) do
          # To prove Direct::Class::Load is set rank
          full_metasploit_cache_nop_class.rank = nil
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
                direct_class: full_metasploit_cache_nop_class,
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

    context 'metasploit_cache_nop_class' do
      subject(:metasploit_cache_nop_class) {
        FactoryGirl.build(:metasploit_cache_nop_class)
      }

      it { is_expected.not_to be_valid }

      context 'Metasploit::Cache::Nop::Class#name' do
        subject(:name) {
          metasploit_cache_nop_class.name
        }

        it { is_expected.to be_nil }
      end
    end
  end
end