RSpec.describe Metasploit::Cache::Payload::Single::Handled::Class do
  it_should_behave_like 'Metasploit::Concern.run'

  context 'assocations' do
    it { is_expected.to belong_to(:payload_single_unhandled_instance).class_name('Metasploit::Cache::Payload::Single::Unhandled::Instance').inverse_of(:payload_single_handled_class) }
  end

  context 'database' do
    context 'columns' do
      it { is_expected.to have_db_column(:payload_single_unhandled_instance_id).of_type(:integer).with_options(null: false) }
    end

    context 'indices' do
      it { is_expected.to have_db_index(:payload_single_unhandled_instance_id).unique(true) }
    end
  end

  context 'factories' do
    context 'metasploit_cache_payload_single_handled_class' do
      include_context ':metasploit_cache_payload_handler_module'

      subject(:metasploit_cache_payload_single_handled_class) {
        FactoryGirl.build(
            :metasploit_cache_payload_single_handled_class,
            payload_single_unhandled_instance_handler_load_pathname: metasploit_cache_payload_handler_module_load_pathname
        )
      }

      it { is_expected.to be_valid }
    end
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:payload_single_unhandled_instance) }

    context 'with pre-existing record' do
      include_context ':metasploit_cache_payload_handler_module'

      let!(:existing_payload_single_handled_class) {
        FactoryGirl.create(
            :metasploit_cache_payload_single_handled_class,
            payload_single_unhandled_instance_handler_load_pathname: metasploit_cache_payload_handler_module_load_pathname
        )
      }

      it { is_expected.to validate_uniqueness_of(:payload_single_unhandled_instance_id) }
    end
  end
end