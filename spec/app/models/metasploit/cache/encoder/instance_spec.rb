RSpec.describe Metasploit::Cache::Encoder::Instance do
  it_should_behave_like 'Metasploit::Concern.run'

  context 'associations' do
    it { is_expected.to have_many(:architectures).class_name('Metasploit::Cache::Architecture') }
    it { is_expected.to have_many(:architecturable_architectures).class_name('Metasploit::Cache::Architecturable::Architecture').dependent(:destroy).inverse_of(:architecturable) }
    it { is_expected.to have_many(:contributions).class_name('Metasploit::Cache::Contribution').dependent(:destroy).inverse_of(:contributable) }
    it { is_expected.to belong_to(:encoder_class).class_name('Metasploit::Cache::Encoder::Class').inverse_of(:encoder_instance) }
    it { is_expected.to have_many(:licensable_licenses).class_name('Metasploit::Cache::Licensable::License')}
    it { is_expected.to have_many(:licenses).class_name('Metasploit::Cache::License')}
  end

  context 'database' do
    context 'columns' do
      it { is_expected.to have_db_column(:description).of_type(:text).with_options(null: false) }
      it { is_expected.to have_db_column(:name).of_type(:string).with_options(null: false) }
    end

    context 'indices' do
      it { is_expected.to have_db_index(:encoder_class_id).unique(true) }
    end
  end

  context 'factories' do
    context 'metasploit_cache_encoder_instance' do
      subject(:metasploit_cache_encoder_instance) {
        FactoryGirl.build(:metasploit_cache_encoder_instance)
      }

      it { is_expected.to be_valid }
      
      context 'metasploit_cache_encoder_instance_encoder_class_ancestor_contents trait' do
        subject(:metasploit_cache_encoder_instance) {
          FactoryGirl.build(
              :metasploit_cache_encoder_instance,
              encoder_class: encoder_class
          )
        }

        context 'with #encoder_class' do
          let(:encoder_class) {
            FactoryGirl.build(
                :metasploit_cache_encoder_class,
                ancestor: encoder_ancestor,
                ancestor_contents?: false
            )
          }

          context 'with Metasploit::Cache::Direct::Class#ancestor' do
            let(:encoder_ancestor) {
              FactoryGirl.build(
                  :metasploit_cache_encoder_ancestor,
                  content?: false,
                  relative_path: relative_path
              )
            }

            context 'with Metasploit::Cache::Module::Ancestor#real_pathname' do
              let(:reference_name) {
                FactoryGirl.generate :metasploit_cache_module_ancestor_reference_name
              }

              let(:relative_path) {
                "encoder/#{reference_name}#{Metasploit::Cache::Module::Ancestor::EXTENSION}"
              }

              it 'writes encoder Metasploit Module to #real_pathname' do
                metasploit_cache_encoder_instance

                expect(encoder_ancestor.real_pathname).to exist
              end
            end

            context 'without Metasploit::Cache::Module::Ancestor#real_pathname' do
              let(:relative_path) {
                nil
              }

              it 'raises ArgumentError' do
                expect {
                  metasploit_cache_encoder_instance
                }.to raise_error(
                         ArgumentError,
                         "Metasploit::Cache::Encoder::Ancestor#real_pathname is `nil` and content cannot be " \
                         "written.  If this is expected, set `encoder_class_ancestor_contents?: false` " \
                         "when using the :metasploit_cache_encoder_instance_encoder_class_ancestor_contents trait."
                     )
              end
            end
          end

          context 'without Metasploit::Cache::Direct::Class#ancestor' do
            let(:encoder_ancestor) {
              nil
            }

            it 'raises ArgumentError' do
              expect {
                metasploit_cache_encoder_instance
              }.to raise_error(
                       ArgumentError,
                       "Metasploit::Cache::Encoder::Class#ancestor is `nil` and content cannot be written.  " \
                       "If this is expected, set `encoder_ancestor_contents?: false` " \
                       "when using the :metasploit_cache_encoder_instance_encoder_class_ancestor_contents trait."
                   )
            end
          end
        end

        context 'without #encoder_class' do
          let(:encoder_class) {
            nil
          }

          it 'raises ArgumentError' do
            expect {
              metasploit_cache_encoder_instance
            }.to raise_error(
                     ArgumentError,
                     "Metasploit::Cache::Encoder::Instance#encoder_class is `nil` and it can't be used to look " \
                     "up Metasploit::Cache::Direct::Class#ancestor to write content. " \
                     "If this is expected, set `encoder_class_ancestor_contents?: false` " \
                     "when using the :metasploit_cache_encoder_instance_encoder_class_ancestor_contents trait."
                 )
          end
        end
      end
    end
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :description }
    it { is_expected.to validate_presence_of :encoder_class }
    it { is_expected.to validate_presence_of :name }

    it_should_behave_like 'validates at least one in association',
                          :contributions,
                          factory: :metasploit_cache_encoder_instance

    it_should_behave_like 'validates at least one in association',
                          :licensable_licenses,
                          factory: :metasploit_cache_encoder_instance

    it_should_behave_like 'validates at least one in association',
                          :platformable_platforms,
                          factory: :metasploit_cache_encoder_instance
  end
end