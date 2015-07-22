RSpec.describe Metasploit::Cache::Auxiliary::Instance, type: :model do
  it_should_behave_like 'Metasploit::Concern.run'

  context 'associations' do
    it { is_expected.to belong_to(:auxiliary_class).class_name('Metasploit::Cache::Auxiliary::Class').inverse_of(:auxiliary_instance) }
    it { is_expected.to have_many(:actions).autosave(true).class_name('Metasploit::Cache::Actionable::Action').dependent(:destroy).inverse_of(:actionable) }
    it { is_expected.to have_many(:contributions).class_name('Metasploit::Cache::Contribution').dependent(:destroy).inverse_of(:contributable) }
    it { is_expected.to belong_to(:default_action).class_name('Metasploit::Cache::Actionable::Action').inverse_of(:actionable) }
    it { is_expected.to have_many(:licensable_licenses).class_name('Metasploit::Cache::Licensable::License').dependent(:destroy).inverse_of(:licensable) }
    it { is_expected.to have_many(:licenses).class_name('Metasploit::Cache::License').through(:licensable_licenses) }
    it { is_expected.to have_many(:referencable_references).class_name('Metasploit::Cache::Referencable::Reference').dependent(:destroy).inverse_of(:referencable) }
    it { is_expected.to have_many(:references).class_name('Metasploit::Cache::Reference').through(:referencable_references) }
  end

  context 'database' do
    context 'columns' do
      it { is_expected.to have_db_column(:auxiliary_class_id).of_type(:integer).with_options(null: false) }
      it { is_expected.to have_db_column(:default_action_id).of_type(:integer).with_options(null: true) }
      it { is_expected.to have_db_column(:description).of_type(:text).with_options(null: false) }
      it { is_expected.to have_db_column(:disclosed_on).of_type(:date).with_options(null: true) }
      it { is_expected.to have_db_column(:name).of_type(:string).with_options(null: false) }
      it { is_expected.to have_db_column(:stance).of_type(:string).with_options(null: false) }
    end

    context 'indices' do
      it { is_expected.to have_db_index([:auxiliary_class_id]).unique(true) }
    end
  end

  context 'factories' do
    context 'metasploit_cache_auxiliary_instance' do
      subject(:metasploit_cache_auxiliary_instance) {
        FactoryGirl.build(:metasploit_cache_auxiliary_instance)
      }

      it { is_expected.to be_valid }

      context 'metasploit_cache_auxiliary_instance_auxiliary_class_ancestor_contents trait' do
        subject(:metasploit_cache_auxiliary_instance) {
          FactoryGirl.build(
              :metasploit_cache_auxiliary_instance,
              auxiliary_class: auxiliary_class
          )
        }

        context 'with #auxiliary_class' do
          let(:auxiliary_class) {
            FactoryGirl.build(
                :metasploit_cache_auxiliary_class,
                ancestor: auxiliary_ancestor,
                ancestor_contents?: false
            )
          }

          context 'with Metasploit::Cache::Direct::Class#ancestor' do
            let(:auxiliary_ancestor) {
              FactoryGirl.build(
                  :metasploit_cache_auxiliary_ancestor,
                  content?: false,
                  relative_path: relative_path
              )
            }

            context 'with Metasploit::Cache::Module::Ancestor#real_pathname' do
              let(:reference_name) {
                FactoryGirl.generate :metasploit_cache_module_ancestor_reference_name
              }

              let(:relative_path) {
                "auxiliary/#{reference_name}#{Metasploit::Cache::Module::Ancestor::EXTENSION}"
              }

              it 'writes auxiliary Metasploit Module to #real_pathname' do
                metasploit_cache_auxiliary_instance

                expect(auxiliary_ancestor.real_pathname).to exist
              end
            end

            context 'without Metasploit::Cache::Module::Ancestor#real_pathname' do
              let(:relative_path) {
                nil
              }

              it 'raises ArgumentError' do
                expect {
                  metasploit_cache_auxiliary_instance
                }.to raise_error(
                         ArgumentError,
                         "Metasploit::Cache::Auxiliary::Ancestor#real_pathname is `nil` and content cannot be " \
                         "written.  If this is expected, set `auxiliary_class_ancestor_contents?: false` " \
                         "when using the :metasploit_cache_auxiliary_instance_auxiliary_class_ancestor_contents trait."
                     )
              end
            end
          end

          context 'without Metasploit::Cache::Direct::Class#ancestor' do
            let(:auxiliary_ancestor) {
              nil
            }

            it 'raises ArgumentError' do
              expect {
                metasploit_cache_auxiliary_instance
              }.to raise_error(
                       ArgumentError,
                       "Metasploit::Cache::Auxiliary::Class#ancestor is `nil` and content cannot be written.  " \
                       "If this is expected, set `auxiliary_ancestor_contents?: false` " \
                       "when using the :metasploit_cache_auxiliary_instance_auxiliary_class_ancestor_contents trait."
                   )
            end
          end
        end

        context 'without #auxiliary_class' do
          let(:auxiliary_class) {
            nil
          }

          it 'raises ArgumentError' do
            expect {
              metasploit_cache_auxiliary_instance
            }.to raise_error(
                     ArgumentError,
                     "Metasploit::Cache::Auxiliary::Instance#auxiliary_class is `nil` and it can't be used to look " \
                     "up Metasploit::Cache::Direct::Class#ancestor to write content. " \
                     "If this is expected, set `auxiliary_class_ancestor_contents?: false` " \
                     "when using the :metasploit_cache_auxiliary_instance_auxiliary_class_ancestor_contents trait."
                 )
          end
        end
      end
    end
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:auxiliary_class) }
    it { is_expected.to validate_presence_of :description }
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_inclusion_of(:stance).in_array(Metasploit::Cache::Module::Stance::ALL) }

    it_should_behave_like 'validates at least one in association',
                          :contributions,
                          factory: :metasploit_cache_auxiliary_instance

    it_should_behave_like 'validates at least one in association',
                          :licensable_licenses,
                          factory: :metasploit_cache_auxiliary_instance

    context 'validates inclusion of #default_action in #actions' do
      subject(:default_action_errors) {
        auxiliary_instance.errors[:default_action]
      }

      let(:error) {
        I18n.translate!('activerecord.errors.models.metasploit/cache/auxiliary/instance.attributes.default_action.inclusion')
      }

      let(:auxiliary_instance) {
        described_class.new
      }

      context 'without #default_action' do
        before(:each) do
          auxiliary_instance.default_action = nil
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
          auxiliary_instance.default_action = default_action
        end

        context 'in #actions' do
          before(:each) do
            auxiliary_instance.actions = [
                default_action
            ]
            auxiliary_instance.valid?
          end

          it { is_expected.not_to include(error) }
        end

        context 'not in #actions' do
          before(:each) do
            auxiliary_instance.actions = []
            auxiliary_instance.valid?
          end

          it { is_expected.to include(error) }
        end
      end
    end
  end
end