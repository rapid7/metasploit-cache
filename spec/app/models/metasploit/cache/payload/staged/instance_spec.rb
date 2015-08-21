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
        include_context 'Metasploit::Cache::Spec::Unload.unload'

        subject(:metasploit_cache_payload_staged_instance) {
          FactoryGirl.build(
              :metasploit_cache_payload_staged_instance,
              payload_staged_class_payload_stager_instance_handler_load_pathname: payload_staged_class_payload_stager_instance_handler_load_pathname
          )
        }

        #
        # lets
        #

        let(:payload_staged_class_payload_stager_instance_handler_load_pathname) {
          Metasploit::Model::Spec.temporary_pathname.join('lib')
        }

        #
        # Callbacks
        #

        around(:each) do |example|
          load_path_before = $LOAD_PATH.dup

          begin
            example.run
          ensure
            $LOAD_PATH.replace(load_path_before)
          end
        end

        before(:each) do
          $LOAD_PATH.unshift payload_staged_class_payload_stager_instance_handler_load_pathname.to_path

          payload_staged_class_payload_stager_instance_handler_load_pathname.mkpath
        end

        it { is_expected.to be_valid }
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
      include_context 'Metasploit::Cache::Spec::Unload.unload'

      #
      # lets
      #

      let(:payload_staged_class_payload_stager_instance_handler_load_pathname) {
        Metasploit::Model::Spec.temporary_pathname.join('lib')
      }

      #
      # Callbacks
      #

      around(:each) do |example|
        load_path_before = $LOAD_PATH.dup

        begin
          example.run
        ensure
          $LOAD_PATH.replace(load_path_before)
        end
      end

      before(:each) do
        $LOAD_PATH.unshift payload_staged_class_payload_stager_instance_handler_load_pathname.to_path

        payload_staged_class_payload_stager_instance_handler_load_pathname.mkpath

        FactoryGirl.create(
            :metasploit_cache_payload_staged_instance,
            payload_staged_class_payload_stager_instance_handler_load_pathname: payload_staged_class_payload_stager_instance_handler_load_pathname
        )
      end

      it { is_expected.to validate_uniqueness_of :payload_staged_class_id }
    end
  end
end