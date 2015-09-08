RSpec.describe Metasploit::Cache::Payload::Staged::Instance do
  context 'associations' do
    it { is_expected.to belong_to(:payload_staged_class).class_name('Metasploit::Cache::Payload::Staged::Class').inverse_of(:payload_staged_instance).with_foreign_key(:payload_staged_class_id) }
  end

  context 'database' do
    context 'columns' do
      it { is_expected.to have_db_column(:payload_staged_class_id).of_type(:integer).with_options(null: false) }
    end

    context 'indices' do
      it { is_expected.to have_db_index([:payload_staged_class_id]).unique(true) }
    end
  end

  context 'factories' do
    context 'metasploit_cache_payload_staged_instance' do
      context 'with :payload_staged_class_payload_stager_instance_handler_load_pathname' do
        include_context 'ActiveSupport::TaggedLogging'
        include_context ':metasploit_cache_payload_handler_module'
        include_context 'Metasploit::Cache::Spec::Unload.unload'

        subject(:metasploit_cache_payload_staged_instance) {
          FactoryGirl.build(
              :metasploit_cache_payload_staged_instance,
              payload_staged_class_payload_stager_instance_handler_load_pathname: metasploit_cache_payload_handler_module_load_pathname
          )
        }

        #
        #
        # lets
        #
        #

        let(:metasploit_framework) {
          double('Metasploit Framework')
        }

        #
        # Stage
        #

        let(:payload_stage_ancestor) {
          payload_stage_class.ancestor
        }

        let(:payload_stage_ancestor_load) {
          Metasploit::Cache::Module::Ancestor::Load.new(
              logger: logger,
              # This should match the major version number of metasploit-framework
              maximum_version: 4,
              module_ancestor: payload_stage_ancestor
          )
        }

        let(:payload_stage_class) {
          payload_stage_instance.payload_stage_class
        }

        let(:payload_stage_class_load) {
          Metasploit::Cache::Payload::Unhandled::Class::Load.new(
              logger: logger,
              metasploit_module: payload_stage_ancestor_load.metasploit_module,
              payload_unhandled_class: payload_stage_class,
              payload_superclass: Metasploit::Cache::Direct::Class::Superclass
          )
        }

        let(:payload_stage_instance) {
          payload_staged_class.payload_stage_instance
        }

        let(:payload_stage_instance_load) {
          Metasploit::Cache::Module::Instance::Load.new(
              ephemeral_class: Metasploit::Cache::Payload::Stage::Instance::Ephemeral,
              logger: logger,
              metasploit_framework: metasploit_framework,
              metasploit_module_class: payload_stage_class_load.metasploit_class,
              module_instance: payload_stage_instance
          )
        }

        #
        # Staged
        #

        let(:payload_staged_class) {
          metasploit_cache_payload_staged_instance.payload_staged_class
        }

        let(:payload_staged_class_load) {
          Metasploit::Cache::Payload::Staged::Class::Load.new(
              handler_module: payload_stager_instance_load.metasploit_module_instance.handler_klass,
              logger: logger,
              payload_stage_metasploit_module: payload_stage_ancestor_load.metasploit_module,
              payload_staged_class: payload_staged_class,
              payload_stager_metasploit_module: payload_stager_ancestor_load.metasploit_module,
              payload_superclass: Metasploit::Cache::Direct::Class::Superclass
          )
        }

        let(:payload_staged_instance_load) {
          Metasploit::Cache::Module::Instance::Load.new(
              ephemeral_class: Metasploit::Cache::Payload::Staged::Instance::Ephemeral,
              logger: logger,
              metasploit_framework: metasploit_framework,
              metasploit_module_class: payload_staged_class_load.metasploit_class,
              module_instance: metasploit_cache_payload_staged_instance
          )
        }

        #
        # Stager
        #

        let(:payload_stager_ancestor) {
          payload_stager_class.ancestor
        }

        let(:payload_stager_ancestor_load) {
          Metasploit::Cache::Module::Ancestor::Load.new(
              # This should match the major version number of metasploit-framework
              maximum_version: 4,
              module_ancestor: payload_stager_ancestor,
              logger: logger
          )
        }

        let(:payload_stager_class) {
          payload_stager_instance.payload_stager_class
        }

        let(:payload_stager_class_load) {
          Metasploit::Cache::Payload::Unhandled::Class::Load.new(
              logger: logger,
              metasploit_module: payload_stager_ancestor_load.metasploit_module,
              payload_unhandled_class: payload_stager_class,
              payload_superclass: Metasploit::Cache::Direct::Class::Superclass
          )
        }

        let(:payload_stager_instance) {
          payload_staged_class.payload_stager_instance
        }

        let(:payload_stager_instance_load) {
          Metasploit::Cache::Module::Instance::Load.new(
              ephemeral_class: Metasploit::Cache::Payload::Stager::Instance::Ephemeral,
              logger: logger,
              metasploit_framework: metasploit_framework,
              metasploit_module_class: payload_stager_class_load.metasploit_class,
              module_instance: payload_stager_instance
          )
        }

        it { is_expected.to be_valid }

        it 'is loadable' do
          expect(payload_staged_instance_load).to be_valid
        end

        context 'Metasploit::Cache::Payload::Staged::Instance#payload_staged_class' do
          it 'is loadable' do
            expect(payload_staged_class_load).to be_valid
          end

          it 'has 2 licenses' do
            payload_staged_class_load.valid?

            expect(
                payload_stage_instance.licenses.map(&:abbreviation)
            ).not_to match_array(
                         payload_stager_instance.licenses.map(&:abbreviation)
                     )
          end

          context 'Metasploit::Cache::Payload::Staged::Class#payload_stage_instance' do
            it 'is loadable' do
              expect(payload_stage_instance_load).to be_valid
            end

            context 'Metasploit::Cache::Payload::Stage::Instance#payload_stage_class' do
              it 'is loadable' do
                expect(payload_stage_class_load).to be_valid
              end

              context 'Metasploit::Cache::Payload::Stage::Class#ancestor' do
                it 'is loadable' do
                  expect(payload_stage_ancestor_load).to be_valid
                end
              end
            end
          end

          context 'Metasploit::Cache::Payload::Staged::Class#payload_stager_instance' do
            it 'is loadable' do
              expect(payload_stager_instance_load).to be_valid
            end

            context 'Metasploit::Cache::Payload::Stager::Instance#payload_stager_class' do
              it 'is loadable' do
                expect(payload_stager_class_load).to be_valid
              end

              context 'Metasploit::Cache::Payload::Stager::Class#ancestor' do
                it 'is loadable' do
                  expect(payload_stager_ancestor_load).to be_valid
                end
              end
            end
          end
        end
      end

      context 'without :payload_staged_class_payload_stager_instance_handler_load_pathname' do
        subject(:metasploit_cache_payload_staged_instance) {
          FactoryGirl.build(:metasploit_cache_payload_staged_instance)
        }

        specify {
          expect {
            metasploit_cache_payload_staged_instance
          }.to raise_error(
                   ArgumentError,
                   ':payload_staged_class_payload_stager_instance_handler_load_pathname must be set for ' \
                   ':metasploit_cache_payload_staged_instance so it can set ' \
                   ':payload_stager_instance_handler_load_pathname for :metasploit_cache_payload_staged_class so it ' \
                   'can set :handler_load_pathname for :metasploit_cache_payload_handable_handler trait so it can ' \
                   'set :load_pathname for :metasploit_cache_payload_handler_module trait'
               )
        }
      end
    end
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :payload_staged_class }

    context 'with existing record' do
      include_context ':metasploit_cache_payload_handler_module'
      include_context 'Metasploit::Cache::Spec::Unload.unload'

      #
      # Callbacks
      #

      before(:each) do
        FactoryGirl.create(
            :metasploit_cache_payload_staged_instance,
            payload_staged_class_payload_stager_instance_handler_load_pathname: metasploit_cache_payload_handler_module_load_pathname
        )
      end

      it { is_expected.to validate_uniqueness_of :payload_staged_class_id }
    end
  end
end