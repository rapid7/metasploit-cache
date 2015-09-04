RSpec.describe Metasploit::Cache::Payload::Single::Handled::Instance do
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