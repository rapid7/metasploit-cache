RSpec.describe Metasploit::Cache::Encoder::Class do
  it_should_behave_like 'Metasploit::Concern.run'

  context 'associations' do
    it { is_expected.to belong_to(:ancestor).class_name('Metasploit::Cache::Encoder::Ancestor') }
    it { is_expected.to belong_to(:rank).class_name('Metasploit::Cache::Module::Rank') }
  end

  context 'factories' do
    context 'metasploit_cache_encoder_class' do
      subject(:metasploit_cache_encoder_class) {
        FactoryGirl.build(:metasploit_cache_encoder_class)
      }

      it { is_expected.to be_valid }

      context 'loading' do
        include_context 'Metasploit::Cache::Module::Ancestor::Spec::Unload.unload'

        let(:logger) {
          ActiveSupport::TaggedLogging.new(
              Logger.new(string_io)
          )
        }

        let(:module_ancestor_load) {
          Metasploit::Cache::Module::Ancestor::Load.new(
              logger: logger,
              maximum_version: 4,
              module_ancestor: metasploit_cache_encoder_class.ancestor
          )
        }

        let(:string_io) {
          StringIO.new
        }

        before(:each) do
          # To prove Direct::Class::Load is set rank
          metasploit_cache_encoder_class.rank = nil
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
                direct_class: metasploit_cache_encoder_class,
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
  end
end