RSpec.describe Metasploit::Cache::Payload::Single::Handled::Instance, type: :model do
  context 'associations' do
    it { is_expected.to belong_to(:payload_single_handled_class).class_name('Metasploit::Cache::Payload::Single::Handled::Class').inverse_of(:payload_single_handled_instance) }
  end

  context 'database' do
    context 'columns' do
      it { is_expected.to have_db_column(:payload_single_handled_class_id).of_type(:integer).with_options(null: false) }
    end

    context 'indices' do
      it { is_expected.to have_db_index(:payload_single_handled_class_id).unique(true) }
    end
  end

  context 'factories' do
    context 'metasploit_cache_payload_single_handled_instance' do
      context 'with :payload_single_handled_class_payload_single_unhandled_instance_handler_load_pathname' do
        include_context ':metasploit_cache_payload_handler_module'

        subject(:metasploit_cache_payload_single_handled_instance) {
          FactoryGirl.build(
              :metasploit_cache_payload_single_handled_instance,
              payload_single_handled_class_payload_single_unhandled_instance_handler_load_pathname: metasploit_cache_payload_handler_module_load_pathname
          )
        }

        it { is_expected.to be_valid }

        context 'loading' do
          include_context 'ActiveSupport::TaggedLogging'
          include_context 'Metasploit::Cache::Spec::Unload.unload'

          let(:metasploit_framework) {
            double('Metasploit::Framework')

          }

          let(:payload_single_ancestor) {
            payload_single_unhandled_class.ancestor
          }

          let(:payload_single_ancestor_load) {
            Metasploit::Cache::Module::Ancestor::Load.new(
                logger: logger,
                # This should match the major version number of metasploit-framework
                maximum_version: 4,
                module_ancestor: payload_single_ancestor
            )
          }

          let(:payload_single_handled_class) {
            metasploit_cache_payload_single_handled_instance.payload_single_handled_class
          }

          let(:payload_single_handled_class_load) {
            Metasploit::Cache::Payload::Single::Handled::Class::Load.new(
                handler_module: payload_single_unhandled_instance_load.metasploit_module_instance.handler_klass,
                logger: logger,
                metasploit_module: payload_single_ancestor_load.metasploit_module,
                payload_single_handled_class: payload_single_handled_class,
                payload_superclass: Msf::Payload
            )
          }

          let(:payload_single_handled_instance_load) {
            Metasploit::Cache::Module::Instance::Load.new(
                ephemeral_class: Metasploit::Cache::Payload::Single::Handled::Instance::Ephemeral,
                logger: logger,
                metasploit_framework: metasploit_framework,
                metasploit_module_class: payload_single_handled_class_load.metasploit_class,
                module_instance: metasploit_cache_payload_single_handled_instance
            )
          }

          let(:payload_single_unhandled_class) {
            payload_single_unhandled_instance.payload_single_unhandled_class
          }

          let(:payload_single_unhandled_class_load) {
            Metasploit::Cache::Payload::Unhandled::Class::Load.new(
                logger: logger,
                metasploit_module: payload_single_ancestor_load.metasploit_module,
                payload_unhandled_class: payload_single_unhandled_class,
                payload_superclass: Msf::Payload
            )
          }

          let(:payload_single_unhandled_instance) {
            payload_single_handled_class.payload_single_unhandled_instance
          }

          let(:payload_single_unhandled_instance_load) {
            Metasploit::Cache::Module::Instance::Load.new(
                ephemeral_class: Metasploit::Cache::Payload::Single::Unhandled::Instance::Ephemeral,
                logger: logger,
                metasploit_framework: metasploit_framework,
                metasploit_module_class: payload_single_unhandled_class_load.metasploit_class,
                module_instance: payload_single_unhandled_instance
            )
          }

          it 'is loadable' do
            expect(payload_single_handled_instance_load).to be_valid
            expect(metasploit_cache_payload_single_handled_instance).to be_persisted
          end

          context 'Metasploit::Cache::Payload::Single::Handled::Instance#payload_single_handled_class' do
            it 'is loadable' do
              expect(payload_single_handled_class_load).to be_valid
              expect(payload_single_handled_class).to be_persisted
            end

            context 'Metasploit::Cache::Payload::Single::Handled::Class#payload_single_unhandled_instance' do
              it 'is loadable' do
                expect(payload_single_unhandled_instance_load).to be_valid
                expect(payload_single_unhandled_instance).to be_persisted
              end

              context 'Metasploit::Cache::Payload::Single::Unhandled::Instance#payload_single_unhandled_class' do
                it 'is loadable' do
                  expect(payload_single_unhandled_class_load).to be_valid
                  expect(payload_single_unhandled_class).to be_persisted
                end

                context 'Metasploit::Cache;:Payload::Single::Unhandled::Class#ancestor' do
                  it 'is loadable' do
                    expect(payload_single_ancestor_load).to be_valid
                    expect(payload_single_ancestor).to be_persisted
                  end
                end
              end
            end
          end
        end
      end

      context 'without :payload_single_handled_class_payload_single_unhandled_instance_handler_load_pathname' do
        subject(:metasploit_cache_payload_single_handled_instance) {
          FactoryGirl.build(:metasploit_cache_payload_single_handled_instance)
        }

        it 'raises ArgumentError' do
          expect {
            metasploit_cache_payload_single_handled_instance
          }.to raise_error(
                   ArgumentError,
                   ':payload_single_handled_class_payload_single_unhandled_instance_handler_load_pathname must be ' \
                   'set for :metasploit_cache_payload_single_handled_instance, so it can set ' \
                   ':payload_single_unhandled_instance_handler_load_path for ' \
                   ':metasploit_cache_payload_single_handled_class, so it can set :handler_load_pathname for ' \
                   ':metasploit_cache_payload_handable_handler trait, so it can set :load_pathname for ' \
                   ':metasploit_cache_payload_handler_module trait'
               )
        end
      end
    end
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :payload_single_handled_class }

    context 'with existing record' do
      include_context ':metasploit_cache_payload_handler_module'

      let!(:existing_payload_single_handled_instance) {
        FactoryGirl.create(
            :metasploit_cache_payload_single_handled_instance,
            payload_single_handled_class_payload_single_unhandled_instance_handler_load_pathname: metasploit_cache_payload_handler_module_load_pathname
        )
      }

      it { is_expected.to validate_uniqueness_of :payload_single_handled_class_id }
    end
  end
end