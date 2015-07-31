RSpec.describe Metasploit::Cache::Encoder::Instance, type: :model do
  it_should_behave_like 'Metasploit::Concern.run'

  context 'associations' do
    it { is_expected.to have_many(:architectures).class_name('Metasploit::Cache::Architecture') }
    it { is_expected.to have_many(:architecturable_architectures).autosave(true).class_name('Metasploit::Cache::Architecturable::Architecture').dependent(:destroy).inverse_of(:architecturable) }
    it { is_expected.to have_many(:contributions).autosave(true).class_name('Metasploit::Cache::Contribution').dependent(:destroy).inverse_of(:contributable) }
    it { is_expected.to belong_to(:encoder_class).class_name('Metasploit::Cache::Encoder::Class').inverse_of(:encoder_instance) }
    it { is_expected.to have_many(:licensable_licenses).autosave(true).class_name('Metasploit::Cache::Licensable::License')}
    it { is_expected.to have_many(:licenses).class_name('Metasploit::Cache::License')}
    it { is_expected.to have_many(:platformable_platforms).autosave(true).class_name('Metasploit::Cache::Platformable::Platform').dependent(:destroy).inverse_of(:platformable) }
    it { is_expected.to have_many(:platforms).class_name('Metasploit::Cache::Platform').through(:platformable_platforms) }
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
                "encoders/#{reference_name}#{Metasploit::Cache::Module::Ancestor::EXTENSION}"
              }

              it 'writes encoder Metasploit Module to #real_pathname' do
                metasploit_cache_encoder_instance

                expect(encoder_ancestor.real_pathname).to exist
              end

              context 'with multiple elements in each association' do
                include_context 'Metasploit::Cache::Spec::Unload.unload'

                subject(:metasploit_cache_encoder_instance) {
                  FactoryGirl.build(
                      :metasploit_cache_encoder_instance,
                      encoder_class: encoder_class,
                      architecturable_architecture_count: architecturable_architecture_count,
                      contribution_count: contribution_count,
                      licensable_license_count: licensable_license_count,
                      platformable_platform_count: platformable_platform_count
                  )
                }

                let(:architecturable_architecture_count) {
                  2
                }

                let(:contribution_count) {
                  2
                }

                let(:direct_class_load) {
                  Metasploit::Cache::Direct::Class::Load.new(
                      direct_class: encoder_class,
                      logger: logger,
                      metasploit_module: module_ancestor_load.metasploit_module
                  )
                }

                let(:licensable_license_count) {
                  2
                }

                let(:logger) {
                  ActiveSupport::TaggedLogging.new(
                      Logger.new(log_string_io)
                  )
                }

                let(:log_string_io) {
                  StringIO.new
                }

                let(:module_ancestor_load) {
                  Metasploit::Cache::Module::Ancestor::Load.new(
                      # This should match the major version number of metasploit-framework
                      maximum_version: 4,
                      module_ancestor: encoder_ancestor,
                      logger: logger
                  )
                }

                let(:module_instance_load) {
                  Metasploit::Cache::Module::Instance::Load.new(
                      ephemeral_class: Metasploit::Cache::Encoder::Instance::Ephemeral,
                      metasploit_module_class: direct_class_load.metasploit_class,
                      module_instance: metasploit_cache_encoder_instance,
                      logger: logger
                  )
                }

                let(:platformable_platform_count) {
                  2
                }

                before(:each) do
                  # ensure file is written for encoder load
                  metasploit_cache_encoder_instance

                  # remove factory records so that load is forced to populate
                  metasploit_cache_encoder_instance.architecturable_architectures = []
                  metasploit_cache_encoder_instance.contributions = []
                  metasploit_cache_encoder_instance.licensable_licenses = []
                  metasploit_cache_encoder_instance.platformable_platforms = []
                end

                it 'is loadable' do
                  expect(module_ancestor_load).to load_metasploit_module

                  expect(direct_class_load).to be_valid
                  expect(encoder_class).to be_persisted

                  expect(module_ancestor_load).to be_valid(:loading)

                  module_instance_load.valid?

                  expect(metasploit_cache_encoder_instance).to be_valid
                  expect(module_instance_load).to be_valid
                  expect(metasploit_cache_encoder_instance).to be_persisted

                  expect(metasploit_cache_encoder_instance.architecturable_architectures.count).to eq(architecturable_architecture_count)
                  expect(metasploit_cache_encoder_instance.contributions.count).to eq(contribution_count)
                  expect(metasploit_cache_encoder_instance.licensable_licenses.count).to eq(licensable_license_count)
                  expect(metasploit_cache_encoder_instance.platformable_platforms.count).to eq(platformable_platform_count)
                end
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