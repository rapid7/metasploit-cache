RSpec.describe Metasploit::Cache::Module::Class::Name do
  context 'associations' do
    it { is_expected.to belong_to(:module_class).inverse_of(:name).with_foreign_key(:module_class_id) }
  end

  context 'database' do
    context 'columns' do
      it { is_expected.to have_db_column(:module_class_id).of_type(:integer).with_options(null: false) }
      it { is_expected.to have_db_column(:module_class_type).of_type(:string).with_options(null: false) }
      it { is_expected.to have_db_column(:module_type).of_type(:string).with_options(null: false) }
      it { is_expected.to have_db_column(:reference).of_type(:string).with_options(null: false) }
    end

    context 'indices' do
      it { is_expected.to have_db_index([:module_class_type, :module_class_id]).unique(true) }
      it { is_expected.to have_db_index([:module_type, :reference]).unique(true) }
    end
  end

  context 'factories' do
    context 'metasploit_cache_module_class_name' do
      context 'with Metasploit::Cache::Direct::Class' do
        subject(:metasploit_cache_module_class_name) {
          FactoryGirl.build(
              :metasploit_cache_module_class_name,
              module_class: module_class,
              module_type: module_type,
              reference: module_class.reference_name
          )
        }

        context 'with Metasploit::Cache::Auxiliary::Class' do
          let(:module_class) {
            FactoryGirl.build(:metasploit_cache_auxiliary_class)
          }

          let(:module_type) {
            'auxiliary'
          }

          it { is_expected.to be_valid }
        end

        context 'with Metasploit::Cache::Encoder::Class' do
          let(:module_class) {
            FactoryGirl.build(:metasploit_cache_encoder_class)
          }

          let(:module_type) {
            'encoder'
          }

          it { is_expected.to be_valid }
        end

        context 'with Metasploit::Cache::Exploit::Class' do
          let(:module_class) {
            FactoryGirl.build(:metasploit_cache_exploit_class)
          }

          let(:module_type) {
            'exploit'
          }

          it { is_expected.to be_valid }
        end

        context 'with Metasploit::Cache::Nop::Class' do
          let(:module_class) {
            FactoryGirl.build(:metasploit_cache_nop_class)
          }

          let(:module_type) {
            'nop'
          }

          it { is_expected.to be_valid }
        end

        context 'with Metasploit::Cache::Post::Class' do
          let(:module_class) {
            FactoryGirl.build(:metasploit_cache_post_class)
          }

          let(:module_type) {
            'post'
          }

          it { is_expected.to be_valid }
        end
      end
    end
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :module_class }
    it { is_expected.to validate_presence_of :module_type }
    it { is_expected.to validate_presence_of :reference }

    context 'with existing record' do
      let!(:existing_module_class_name) {
        FactoryGirl.create(:metasploit_cache_auxiliary_class_name)
      }

      context 'validates uniqueness of module_class_id scoped to module_class_type ' do
        #
        # lets
        #

        let(:error) {
          I18n.translate!('errors.messages.taken')
        }

        let(:module_class_id_errors) {
          module_class_name.errors[:module_class_id]
        }

        #
        # let!s
        #

        let!(:existing_module_class) {
          existing_module_class_name.module_class
        }

        #
        # Callbacks
        #

        before(:each) do
          module_class_name.valid?
        end

        context 'with same module_class_type' do
          let(:module_class_type) {
            existing_module_class.name.module_class_type
          }

          context 'with same module_class_id' do
            let(:module_class_name) {
              described_class.new(
                  module_class_id: existing_module_class.id,
                  module_class_type: module_class_type
              )
            }

            it 'add error on module_class_id' do
              expect(module_class_id_errors).to include(error)
            end
          end

          context 'with different module_class_id' do
            let(:module_class_name) {
              described_class.new(
                  module_class_id: existing_module_class.id + 1,
                  module_class_type: module_class_type
              )
            }

            it 'does not add error on module_class_id' do
              expect(module_class_id_errors).not_to include(error)
            end
          end
        end

        context 'with different module_class_type' do
          let(:module_class_type) {
            'Metasploit::Cache::Payload::Single::Handled::Class'
          }

          context 'with same module_class_id' do
            let(:module_class_name) {
              described_class.new(
                  module_class_id: existing_module_class.id,
                  module_class_type: module_class_type
              )
            }

            it 'does not add error on module_class_id' do
              expect(module_class_id_errors).not_to include(error)
            end
          end

          context 'with different module_class_id' do
            let(:module_class_name) {
              described_class.new(
                  module_class_id: existing_module_class.id + 1,
                  module_class_type: module_class_type
              )
            }

            it 'does not add error on module_class_id' do
              expect(module_class_id_errors).not_to include(error)
            end
          end
        end
      end

      it { is_expected.to validate_uniqueness_of(:reference).scoped_to(:module_type) }
    end
  end
end