RSpec.describe Metasploit::Cache::Payload::Stager::Instance, type: :model do
  it_should_behave_like 'Metasploit::Concern.run'

  context 'associations' do
    it { is_expected.to have_many(:architectures).class_name('Metasploit::Cache::Architecture') }
    it { is_expected.to have_many(:architecturable_architectures).autosave(true).class_name('Metasploit::Cache::Architecturable::Architecture').dependent(:destroy).inverse_of(:architecturable) }
    it { is_expected.to have_many(:contributions).autosave(true).class_name('Metasploit::Cache::Contribution').dependent(:destroy).inverse_of(:contributable) }
    it { is_expected.to belong_to(:handler).class_name('Metasploit::Cache::Payload::Handler').inverse_of(:payload_stager_instances) }
    it { is_expected.to have_many(:licensable_licenses).autosave(true).class_name('Metasploit::Cache::Licensable::License').dependent(:destroy).inverse_of(:licensable) }
    it { is_expected.to have_many(:licenses).class_name('Metasploit::Cache::License').through(:licensable_licenses) }
    it { is_expected.to have_many(:payload_staged_classes).class_name('Metasploit::Cache::Payload::Staged::Class').dependent(:destroy).inverse_of(:payload_stager_instance) }
    it { is_expected.to belong_to(:payload_stager_class).class_name('Metasploit::Cache::Payload::Stager::Class').inverse_of(:payload_stager_instance).with_foreign_key(:payload_stager_class_id) }
    it { is_expected.to have_many(:platforms).class_name('Metasploit::Cache::Platform') }
    it { is_expected.to have_many(:platformable_platforms).autosave(true).class_name('Metasploit::Cache::Platformable::Platform').inverse_of(:platformable) }
  end

  context 'database' do
    context 'columns' do
      it { is_expected.to have_db_column(:description).of_type(:text).with_options(null: false) }
      it { is_expected.to have_db_column(:handler_id).of_type(:integer).with_options(null: false) }
      it { is_expected.to have_db_column(:handler_type_alias).of_type(:string).with_options(null: true) }
      it { is_expected.to have_db_column(:name).of_type(:string).with_options(null: false) }
      it { is_expected.to have_db_column(:payload_stager_class_id).of_type(:integer).with_options(null: false) }
      it { is_expected.to have_db_column(:privileged).of_type(:boolean).with_options(null: false) }
    end

    context 'indices' do
      it { is_expected.to have_db_index(:handler_id).unique(false) }
      it { is_expected.to have_db_index(:payload_stager_class_id).unique(true) }
    end
  end

  context 'factories' do
    context 'full_metasploit_cache_payload_stager_instance' do
      context 'with :handler_load_pathname' do
        include_context ':metasploit_cache_payload_handler_module'
        include_context 'Metasploit::Cache::Spec::Unload.unload'

        subject(:full_metasploit_cache_payload_stager_instance) {
          FactoryGirl.build(
              :full_metasploit_cache_payload_stager_instance,
              handler_load_pathname: metasploit_cache_payload_handler_module_load_pathname
          )
        }

        #
        # Callbacks
        #

        before(:each) do
          FactoryGirl.create(
              :full_metasploit_cache_payload_single_unhandled_instance,
              handler_load_pathname: metasploit_cache_payload_handler_module_load_pathname
          )
        end

        it { is_expected.to be_valid }

        context 'metasploit_cache_payload_stager_instance_payload_stager_class_ancestor_contents trait' do
          subject(:full_metasploit_cache_payload_stager_instance) {
            FactoryGirl.build(
                :full_metasploit_cache_payload_stager_instance,
                handler_load_pathname: metasploit_cache_payload_handler_module_load_pathname,
                payload_stager_class: payload_stager_class
            )
          }

          context 'with #payload_stager_class' do
            let(:payload_stager_class) {
              FactoryGirl.build(
                  :metasploit_cache_payload_stager_class,
                  ancestor: payload_stager_ancestor,
                  ancestor_contents?: false
              )
            }

            context 'with Metasploit::Cache::Direct::Class#ancestor' do
              let(:payload_stager_ancestor) {
                FactoryGirl.build(
                    :metasploit_cache_payload_stager_ancestor,
                    content?: false,
                    relative_path: relative_path
                )
              }

              context 'with Metasploit::Cache::Module::Ancestor#real_pathname' do
                let(:payload_name) {
                  FactoryGirl.generate :metasploit_cache_payload_ancestor_payload_name
                }

                let(:relative_path) {
                  "payloads/stagers/#{payload_name}#{Metasploit::Cache::Module::Ancestor::EXTENSION}"
                }

                it 'writes payload_stager Metasploit Module to #real_pathname' do
                  full_metasploit_cache_payload_stager_instance

                  expect(payload_stager_ancestor.real_pathname).to exist
                end

                context 'with multiple elements in each association' do
                  include_context 'ActiveSupport::TaggedLogging'
                  include_context 'Metasploit::Cache::Spec::Unload.unload'

                  subject(:full_metasploit_cache_payload_stager_instance) {
                    FactoryGirl.build(
                        :metasploit_cache_payload_stager_instance,
                        :metasploit_cache_architecturable_architecturable_architectures,
                        :metasploit_cache_contributable_contributions,
                        :metasploit_cache_licensable_licensable_licenses,
                        :metasploit_cache_platformable_platformable_platforms,
                        :metasploit_cache_payload_handable_handler,
                        :metasploit_cache_payload_stager_instance_payload_stager_class_ancestor_contents,
                        architecturable_architecture_count: architecturable_architecture_count,
                        contribution_count: contribution_count,
                        handler_load_pathname: metasploit_cache_payload_handler_module_load_pathname,
                        licensable_license_count: licensable_license_count,
                        payload_stager_class: payload_stager_class,
                        platformable_platform_count: platformable_platform_count
                    )
                  }

                  #
                  # lets
                  #

                  let(:architecturable_architecture_count) {
                    2
                  }

                  let(:contribution_count) {
                    2
                  }

                  let(:licensable_license_count) {
                    2
                  }

                  let(:metasploit_framework) {
                    double('Metasploit::Framework')
                  }

                  let(:module_ancestor_load) {
                    Metasploit::Cache::Module::Ancestor::Load.new(
                        # This should match the major version number of metasploit-framework
                        maximum_version: 4,
                        module_ancestor: payload_stager_ancestor,
                        logger: logger
                    )
                  }

                  let(:module_instance_load) {
                    Metasploit::Cache::Module::Instance::Load.new(
                        persister_class: Metasploit::Cache::Payload::Stager::Instance::Persister,
                        logger: logger,
                        metasploit_framework: metasploit_framework,
                        metasploit_module_class: payload_unhandled_class_load.metasploit_class,
                        module_instance: full_metasploit_cache_payload_stager_instance
                    )
                  }

                  let(:payload_unhandled_class_load) {
                    Metasploit::Cache::Payload::Unhandled::Class::Load.new(
                        logger: logger,
                        metasploit_module: module_ancestor_load.metasploit_module,
                        payload_unhandled_class: payload_stager_class,
                        payload_superclass: Metasploit::Cache::Direct::Class::Superclass
                    )
                  }

                  let(:platformable_platform_count) {
                    2
                  }

                  #
                  # Callbacks
                  #

                  before(:each) do
                    # ensure file is written for encoder load
                    full_metasploit_cache_payload_stager_instance

                    # remove factory records so that load is forced to populate
                    full_metasploit_cache_payload_stager_instance.architecturable_architectures = []
                    full_metasploit_cache_payload_stager_instance.contributions = []
                    full_metasploit_cache_payload_stager_instance.licensable_licenses = []
                    full_metasploit_cache_payload_stager_instance.platformable_platforms = []
                  end

                  it 'is loadable' do
                    expect(module_ancestor_load).to load_metasploit_module

                    expect(payload_unhandled_class_load).to be_valid
                    expect(payload_stager_class).to be_persisted

                    expect(module_instance_load).to be_valid(:loading)

                    module_instance_load.valid?

                    unless full_metasploit_cache_payload_stager_instance.valid?
                      # Only covered on failure
                      # :nocov:
                      fail "Expected #{full_metasploit_cache_payload_stager_instance.class} to be valid, but got errors:\n" \
                         "#{full_metasploit_cache_payload_stager_instance.errors.full_messages.join("\n")}\n" \
                         "\n" \
                         "Log:\n" \
                         "#{log_string_io.string}\n" \
                         "Expected #{module_instance_load.class} to be valid, but got errors:\n" \
                         "#{module_instance_load.errors.full_messages.join("\n")}"
                      # :nocov:
                    end

                    expect(module_instance_load).to be_valid
                    expect(full_metasploit_cache_payload_stager_instance).to be_persisted

                    expect(full_metasploit_cache_payload_stager_instance.architecturable_architectures.count).to eq(architecturable_architecture_count)
                    expect(full_metasploit_cache_payload_stager_instance.contributions.count).to eq(contribution_count)
                    expect(full_metasploit_cache_payload_stager_instance.licensable_licenses.count).to eq(licensable_license_count)
                    expect(full_metasploit_cache_payload_stager_instance.platformable_platforms.count).to eq(platformable_platform_count)
                  end
                end
              end

              context 'without Metasploit::Cache::Module::Ancestor#real_pathname' do
                let(:relative_path) {
                  nil
                }

                it 'raises ArgumentError' do
                  expect {
                    full_metasploit_cache_payload_stager_instance
                  }.to raise_error(
                           ArgumentError,
                           'Metasploit::Cache::Payload::Stager::Ancestor#real_pathname is `nil` and content cannot be ' \
                         'written.'
                       )
                end
              end
            end

            context 'without Metasploit::Cache::Direct::Class#ancestor' do
              let(:payload_stager_ancestor) {
                nil
              }

              it 'raises ArgumentError' do
                expect {
                  full_metasploit_cache_payload_stager_instance
                }.to raise_error(
                         ArgumentError,
                         'Metasploit::Cache::Payload::Stager::Class#ancestor is `nil` and content cannot be written.'
                     )
              end
            end
          end

          context 'without #payload_stager_class' do
            let(:payload_stager_class) {
              nil
            }

            it 'raises ArgumentError' do
              expect {
                full_metasploit_cache_payload_stager_instance
              }.to raise_error(
                       ArgumentError,
                       "Metasploit::Cache::Payload::Stager::Instance#payload_stager_class is `nil` and it can't be " \
                     'used to look up Metasploit::Cache::Direct::Class#ancestor to write content.'
                   )
            end
          end
        end
      end

      context 'without :handler_load_pathname' do
        subject(:full_metasploit_cache_payload_stager_instance) {
          FactoryGirl.build(:full_metasploit_cache_payload_stager_instance)
        }

        specify {
          expect {
            full_metasploit_cache_payload_stager_instance
          }.to raise_error(
                   ArgumentError,
                   ':handler_load_pathname must be set for :metasploit_cache_payload_handable_handler trait so it ' \
                   'can set :load_pathname for :metasploit_cache_payload_handler_module trait'
               )
        }
      end
    end

    context 'metasploit_cache_payload_stager_instance' do
      subject(:metasploit_cache_payload_stager_instance) {
        FactoryGirl.build(:metasploit_cache_payload_stager_instance)
      }

      it { is_expected.not_to be_valid }
    end
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :description }
    it { is_expected.to validate_presence_of :handler }
    it { is_expected.not_to validate_presence_of :handler_type_alias }
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :payload_stager_class }
    it { is_expected.to validate_inclusion_of(:privileged).in_array([false, true]) }

    it_should_behave_like 'validates at least one in association',
                          :architecturable_architectures,
                          factory: :metasploit_cache_payload_stager_instance,
                          traits: [:metasploit_cache_architecturable_architecturable_architectures]

    it_should_behave_like 'validates at least one in association',
                          :contributions,
                          factory: :metasploit_cache_payload_stager_instance,
                          traits: [:metasploit_cache_contributable_contributions]

    it_should_behave_like 'validates at least one in association',
                          :licensable_licenses,
                          factory: :metasploit_cache_payload_stager_instance,
                          traits: [:metasploit_cache_licensable_licensable_licenses]

    it_should_behave_like 'validates at least one in association',
                          :platformable_platforms,
                          factory: :metasploit_cache_payload_stager_instance,
                          traits: [:metasploit_cache_platformable_platformable_platforms]

    # validate_uniqueness_of needs a pre-existing record of the same class to work correctly when the `null: false`
    # constraints exist for other fields.
    context 'with existing record' do
      include_context ':metasploit_cache_payload_handler_module'
      include_context 'Metasploit::Cache::Spec::Unload.unload'

      #
      # Callbacks
      #

      before(:each) do
        FactoryGirl.create(
            :full_metasploit_cache_payload_stager_instance,
            handler_load_pathname: metasploit_cache_payload_handler_module_load_pathname
        )
      end

      it { is_expected.to validate_uniqueness_of :payload_stager_class_id }
    end
  end
end