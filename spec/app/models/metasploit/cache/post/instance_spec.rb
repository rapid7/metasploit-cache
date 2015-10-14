RSpec.describe Metasploit::Cache::Post::Instance, type: :model do
  it_should_behave_like 'Metasploit::Concern.run'

  context 'associations' do
    it { is_expected.to have_many(:architectures).class_name('Metasploit::Cache::Architecture') }
    it { is_expected.to have_many(:architecturable_architectures).autosave(true).class_name('Metasploit::Cache::Architecturable::Architecture').dependent(:destroy).inverse_of(:architecturable) }
    it { is_expected.to have_many(:actions).autosave(true).class_name('Metasploit::Cache::Actionable::Action').inverse_of(:actionable) }
    it { is_expected.to have_many(:contributions).autosave(true).class_name('Metasploit::Cache::Contribution').dependent(:destroy).inverse_of(:contributable) }
    it { is_expected.to belong_to(:default_action).class_name('Metasploit::Cache::Actionable::Action').inverse_of(:actionable) }
    it { is_expected.to have_many(:licensable_licenses).autosave(true).class_name('Metasploit::Cache::Licensable::License').dependent(:destroy).inverse_of(:licensable) }
    it { is_expected.to have_many(:licenses).class_name('Metasploit::Cache::License').through(:licensable_licenses) }
    it { is_expected.to have_many(:platforms).class_name('Metasploit::Cache::Platform') }
    it { is_expected.to have_many(:platformable_platforms).class_name('Metasploit::Cache::Platformable::Platform').inverse_of(:platformable) }
    it { is_expected.to belong_to(:post_class).class_name('Metasploit::Cache::Post::Class').inverse_of(:post_instance).with_foreign_key(:post_class_id) }
    it { is_expected.to have_many(:referencable_references).autosave(true).class_name('Metasploit::Cache::Referencable::Reference').dependent(:destroy).inverse_of(:referencable) }
    it { is_expected.to have_many(:references).class_name('Metasploit::Cache::Reference').through(:referencable_references) }
  end

  context 'database' do
    context 'columns' do
      it { is_expected.to have_db_column(:default_action_id).of_type(:integer).with_options(null: true) }
      it { is_expected.to have_db_column(:description).of_type(:text).with_options(null: false) }
      it { is_expected.to have_db_column(:disclosed_on).of_type(:date).with_options(null: true) }
      it { is_expected.to have_db_column(:name).of_type(:string).with_options(null: false) }
      it { is_expected.to have_db_column(:post_class_id).of_type(:integer).with_options(null: false) }
      it { is_expected.to have_db_column(:privileged).of_type(:boolean).with_options(null: false) }
    end

    context 'indices' do
      it { is_expected.to have_db_index(:default_action_id).unique(true) }
      it { is_expected.to have_db_index(:post_class_id).unique(true) }
    end
  end

  context 'factories' do
    context 'full_metasploit_cache_post_instance' do
      subject(:full_metasploit_cache_post_instance) {
        FactoryGirl.build(:full_metasploit_cache_post_instance)
      }

      it { is_expected.to be_valid }

      context 'metasploit_cache_post_instance_post_class_ancestor_contents trait' do
        subject(:full_metasploit_cache_post_instance) {
          FactoryGirl.build(
              :full_metasploit_cache_post_instance,
              post_class: post_class
          )
        }

        context 'with #post_class' do
          let(:post_class) {
            FactoryGirl.build(
                :full_metasploit_cache_post_class,
                ancestor: post_ancestor,
                ancestor_contents?: false
            )
          }

          context 'with Metasploit::Cache::Direct::Class#ancestor' do
            let(:post_ancestor) {
              FactoryGirl.build(
                  :metasploit_cache_post_ancestor,
                  content?: false,
                  relative_path: relative_path
              )
            }

            context 'with Metasploit::Cache::Module::Ancestor#real_pathname' do
              let(:reference_name) {
                FactoryGirl.generate :metasploit_cache_module_ancestor_reference_name
              }

              let(:relative_path) {
                "post/#{reference_name}#{Metasploit::Cache::Module::Ancestor::EXTENSION}"
              }

              it 'writes post Metasploit Module to #real_pathname' do
                full_metasploit_cache_post_instance

                expect(post_ancestor.real_pathname).to exist
              end

              context 'with multiple elements in each association' do
                include_context 'ActiveSupport::TaggedLogging'
                include_context 'Metasploit::Cache::Spec::Unload.unload'

                subject(:full_metasploit_cache_post_instance) {
                  FactoryGirl.build(
                      :metasploit_cache_post_instance,
                      :metasploit_cache_actionable_actions,
                      :metasploit_cache_architecturable_architecturable_architectures,
                      :metasploit_cache_contributable_contributions,
                      :metasploit_cache_licensable_licensable_licenses,
                      :metasploit_cache_platformable_platformable_platforms,
                      :metasploit_cache_referencable_referencable_references,
                      :metasploit_cache_post_instance_post_class_ancestor_contents,
                      action_count: action_count,
                      architecturable_architecture_count: architecturable_architecture_count,
                      contribution_count: contribution_count,
                      licensable_license_count: licensable_license_count,
                      post_class: post_class,
                      platformable_platform_count: platformable_platform_count,
                      referencable_reference_count: referencable_reference_count
                  )
                }

                #
                # lets
                #

                let(:action_count) {
                  2
                }

                let(:architecturable_architecture_count) {
                  2
                }

                let(:contribution_count) {
                  2
                }

                let(:direct_class_load) {
                  Metasploit::Cache::Direct::Class::Load.new(
                      direct_class: post_class,
                      logger: logger,
                      metasploit_module: module_ancestor_load.metasploit_module
                  )
                }

                let(:licensable_license_count) {
                  2
                }

                let(:metasploit_framework) {
                  double('Metasploit::Framework')
                }

                let(:module_ancestor_load) {
                  Metasploit::Cache::Module::Ancestor::Load.new(
                      logger: logger,
                      # This should match the major version number of metasploit-framework
                      maximum_version: 4,
                      module_ancestor: post_ancestor,
                      persister_class: Metasploit::Cache::Module::Ancestor::Persister
                  )
                }

                let(:module_instance_load) {
                  Metasploit::Cache::Module::Instance::Load.new(
                      persister_class: Metasploit::Cache::Post::Instance::Persister,
                      logger: logger,
                      metasploit_framework: metasploit_framework,
                      metasploit_module_class: direct_class_load.metasploit_class,
                      module_instance: full_metasploit_cache_post_instance
                  )
                }

                let(:platformable_platform_count) {
                  2
                }

                let(:referencable_reference_count) {
                  2
                }

                #
                # Callbacks
                #

                before(:each) do
                  # ensure file is written for encoder load
                  full_metasploit_cache_post_instance

                  # remove factory records so that load is forced to populate
                  full_metasploit_cache_post_instance.actions = []
                  full_metasploit_cache_post_instance.architecturable_architectures = []
                  full_metasploit_cache_post_instance.contributions = []
                  full_metasploit_cache_post_instance.licensable_licenses = []
                  full_metasploit_cache_post_instance.platformable_platforms = []
                  full_metasploit_cache_post_instance.referencable_references = []
                end

                it 'is loadable' do
                  expect(module_ancestor_load).to load_metasploit_module

                  expect(direct_class_load).to be_valid
                  expect(post_class).to be_persisted

                  expect(module_instance_load).to be_valid(:loading)

                  module_instance_load.valid?

                  unless full_metasploit_cache_post_instance.valid?
                    # Only covered on failure
                    # :nocov:
                    fail "Expected #{full_metasploit_cache_post_instance.class} to be valid, but got errors:\n" \
                         "#{full_metasploit_cache_post_instance.errors.full_messages.join("\n")}\n" \
                         "\n" \
                         "Log:\n" \
                         "#{log_string_io.string}\n" \
                         "Expected #{module_instance_load.class} to be valid, but got errors:\n" \
                         "#{module_instance_load.errors.full_messages.join("\n")}"
                    # :nocov:
                  end

                  expect(module_instance_load).to be_valid
                  expect(full_metasploit_cache_post_instance).to be_persisted

                  expect(full_metasploit_cache_post_instance.actions.count).to eq(action_count)
                  expect(full_metasploit_cache_post_instance.architecturable_architectures.count).to eq(architecturable_architecture_count)
                  expect(full_metasploit_cache_post_instance.contributions.count).to eq(contribution_count)
                  expect(full_metasploit_cache_post_instance.licensable_licenses.count).to eq(licensable_license_count)
                  expect(full_metasploit_cache_post_instance.platformable_platforms.count).to eq(platformable_platform_count)
                  expect(full_metasploit_cache_post_instance.referencable_references.count).to eq(referencable_reference_count)
                end
              end
            end

            context 'without Metasploit::Cache::Module::Ancestor#real_pathname' do
              let(:relative_path) {
                nil
              }

              it 'raises ArgumentError' do
                expect {
                  full_metasploit_cache_post_instance
                }.to raise_error(
                         ArgumentError,
                         'Metasploit::Cache::Post::Ancestor#real_pathname is `nil` and content cannot be ' \
                         'written.  If this is expected, set `post_class_ancestor_contents?: false` ' \
                         'when using the :metasploit_cache_post_instance_post_class_ancestor_contents trait.'
                     )
              end
            end
          end

          context 'without Metasploit::Cache::Direct::Class#ancestor' do
            let(:post_ancestor) {
              nil
            }

            it 'raises ArgumentError' do
              expect {
                full_metasploit_cache_post_instance
              }.to raise_error(
                       ArgumentError,
                       'Metasploit::Cache::Post::Class#ancestor is `nil` and content cannot be written.  ' \
                       'If this is expected, set `post_ancestor_contents?: false` ' \
                       'when using the :metasploit_cache_post_instance_post_class_ancestor_contents trait.'
                   )
            end
          end
        end

        context 'without #post_class' do
          let(:post_class) {
            nil
          }

          it 'raises ArgumentError' do
            expect {
              full_metasploit_cache_post_instance
            }.to raise_error(
                     ArgumentError,
                     "Metasploit::Cache::Post::Instance#post_class is `nil` and it can't be used to look " \
                     "up Metasploit::Cache::Direct::Class#ancestor to write content. " \
                     "If this is expected, set `post_class_ancestor_contents?: false` " \
                     "when using the :metasploit_cache_post_instance_post_class_ancestor_contents trait."
                 )
          end
        end
      end
    end

    context 'metasploit_cache_post_instance' do
      subject(:metasploit_cache_post_instance) {
        FactoryGirl.build(:metasploit_cache_post_instance)
      }

      it { is_expected.not_to be_valid }
    end
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :description }
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :post_class }
    it { is_expected.to validate_inclusion_of(:privileged).in_array([false, true]) }

    it_should_behave_like 'validates at least one in association',
                          :architecturable_architectures,
                          factory: :metasploit_cache_post_instance,
                          traits: [:metasploit_cache_architecturable_architecturable_architectures]

    it_should_behave_like 'validates at least one in association',
                          :contributions,
                          factory: :metasploit_cache_post_instance,
                          traits: [:metasploit_cache_contributable_contributions]

    it_should_behave_like 'validates at least one in association',
                          :licensable_licenses,
                          factory: :metasploit_cache_post_instance,
                          traits: [:metasploit_cache_licensable_licensable_licenses]

    it_should_behave_like 'validates at least one in association',
                          :platformable_platforms,
                          factory: :metasploit_cache_post_instance,
                          traits: [:metasploit_cache_platformable_platformable_platforms]

    context 'validates inclusion of #default_action in #actions' do
      subject(:default_action_errors) {
        post_instance.errors[:default_action]
      }

      let(:error) {
        I18n.translate!('activerecord.errors.models.metasploit/cache/post/instance.attributes.default_action.inclusion')
      }

      let(:post_instance) {
        described_class.new
      }

      context 'without #default_action' do
        before(:each) do
          post_instance.default_action = nil
        end

        it { is_expected.not_to include(error) }
      end

      context 'with #default_action' do
        #
        # lets
        #

        let(:default_action) {
          Metasploit::Cache::Actionable::Action.new
        }

        #
        # Callbacks
        #

        before(:each) do
          post_instance.default_action = default_action
        end

        context 'in #actions' do
          before(:each) do
            post_instance.actions = [
                default_action
            ]
            post_instance.valid?
          end

          it { is_expected.not_to include(error) }
        end

        context 'not in #actions' do
          before(:each) do
            post_instance.actions = []
            post_instance.valid?
          end

          it { is_expected.to include(error) }
        end
      end
    end

    # validate_uniqueness_of needs a pre-existing record of the same class to work correctly when the `null: false`
    # constraints exist for other fields.
    context 'with existing record' do
      let!(:existing_post_instance) {
        FactoryGirl.create(
            :full_metasploit_cache_post_instance
        )
      }

      it { is_expected.to validate_uniqueness_of :post_class_id }
    end
  end
end