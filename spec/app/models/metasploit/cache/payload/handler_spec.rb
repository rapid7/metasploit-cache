RSpec.describe Metasploit::Cache::Payload::Handler, type: :model do
  context 'associations' do
    it { is_expected.to have_many(:payload_single_unhandled_instances).class_name('Metasploit::Cache::Payload::Single::Unhandled::Instance').dependent(:destroy).inverse_of(:handler) }
    it { is_expected.to have_many(:payload_stager_instances).class_name('Metasploit::Cache::Payload::Stager::Instance').dependent(:destroy).inverse_of(:handler) }
  end

  context 'database' do
    context 'columns' do
      it { is_expected.to have_db_column(:general_handler_type).of_type(:string).with_options(null: false) }
      it { is_expected.to have_db_column(:handler_type).of_type(:string).with_options(null: false) }
      it { is_expected.to have_db_column(:name).of_type(:string).with_options(null: false) }
    end

    context 'indices' do
      it { is_expected.to have_db_index(:handler_type).unique(true) }
      it { is_expected.to have_db_index(:name).unique(true) }
    end
  end

  context 'factories' do
    context 'full_metasploit_cache_payload_handler' do
      subject(:full_metasploit_cache_payload_handler) {
        FactoryGirl.build(
            :full_metasploit_cache_payload_handler,
            load_pathname: load_pathname
        )
      }

      context 'with :load_pathname' do
        include_context ':metasploit_cache_payload_handler_module'
        include_context 'Metasploit::Cache::Spec::Unload.unload'

        #
        # lets
        #

        let(:handler_module) {
          full_metasploit_cache_payload_handler.name.constantize
        }

        let(:load_pathname) {
          metasploit_cache_payload_handler_module_load_pathname
        }

        it { is_expected.to be_valid }

        it 'is loadable' do
          expect {
            handler_module
          }.not_to raise_error
        end

        context 'loaded Module' do
          subject {
            handler_module
          }

          it { is_expected.not_to be_a Class }
          it { is_expected.to be_a Module }

          context 'general_handler_type' do
            subject(:general_handler_type) {
              handler_module.general_handler_type
            }

            it 'matches Metasploit::Cache::Payload::Handler#general_handler_type' do
              expect(general_handler_type).to eq(full_metasploit_cache_payload_handler.general_handler_type)
            end
          end

          context 'handler_type' do
            subject(:handler_type) {
              handler_module.handler_type
            }

            it 'matches Metasploit::Cache::Payload::Handler#handler_type' do
              expect(handler_type).to eq(full_metasploit_cache_payload_handler.handler_type)
            end
          end
        end
      end

      context 'without :load_pathname' do
        let(:load_pathname) {
          nil
        }

        specify {
          expect {
            full_metasploit_cache_payload_handler
          }.to raise_error(
                   ArgumentError,
                   'load_path must be set for :metasploit_cache_payload_handler_module traits so the Module is ' \
                   'written to a path that can be loaded with String#constantize'
               )
        }
      end
    end

    context 'metasploit_cache_payload_handler' do
      subject(:metasploit_cache_payload_handler) {
        FactoryGirl.build(:metasploit_cache_payload_handler)
      }

      it { is_expected.to be_valid }
    end
  end

  context 'validations' do
    it { is_expected.to validate_inclusion_of(:general_handler_type).in_array(Metasploit::Cache::Payload::Handler::GeneralType::ALL) }
    it { is_expected.to validate_presence_of :handler_type }
    it { is_expected.to validate_presence_of :name }

    # validate_uniqueness_of needs a pre-existing record of the same class to work correctly when the `null: false`
    # constraints exist for other fields.
    context 'with existing record' do
      let!(:existing_payload_handler) {
        FactoryGirl.create(
            :metasploit_cache_payload_handler
        )
      }

      it { is_expected.to validate_uniqueness_of :handler_type }
      it { is_expected.to validate_uniqueness_of :name }
    end
  end

  it_should_behave_like 'Metasploit::Concern.run'
end