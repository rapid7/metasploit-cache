RSpec.describe Metasploit::Cache::Encoder::Instance do
  it_should_behave_like 'Metasploit::Concern.run'

  context 'associations' do
    it { is_expected.to have_many(:architectures).class_name('Metasploit::Cache::Architecture') }
    it { is_expected.to have_many(:architecturable_architectures).class_name('Metasploit::Cache::Architecturable::Architecture').dependent(:destroy).inverse_of(:architecturable) }
    it { is_expected.to belong_to(:encoder_class).class_name('Metasploit::Cache::Encoder::Class').inverse_of(:encoder_instance) }
  end

  context 'database' do
    context 'columns' do
      it { is_expected.to have_db_column(:description).of_type(:text).with_options(null: false) }
      it { is_expected.to have_db_column(:name).of_type(:string).with_options(null: false) }
    end

    context 'indices' do
      it { is_expected.to have_db_index(:encoder_class_id).unique(true) }
    end
  end

  context 'factories' do
    context 'metasploit_cache_encoder_instance' do
      subject(:metasploit_cache_encoder_instance) {
        FactoryGirl.build(:metasploit_cache_encoder_instance)
      }

      it { is_expected.to be_valid }
    end
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :description }
    it { is_expected.to validate_presence_of :encoder_class }
    it { is_expected.to validate_presence_of :name }

    # validate_length_of from shoulda-matchers assumes attribute is String and doesn't work on associations
    context 'validates length of architecturable_architectures is at least 1' do
      let(:error) {
        I18n.translate!(
          'activerecord.errors.models.metasploit/cache/encoder/instance.attributes.architecturable_architectures.too_short',
           count: 1
        )
      }

      context 'without architecturable_architectures' do
        subject(:encoder_instance) {
          FactoryGirl.build(
              :metasploit_cache_encoder_instance,
              architecturable_architecture_count: 0
          )
        }

        it 'adds error on #architecturable_architectures' do
          encoder_instance.valid?

          expect(encoder_instance.errors[:architecturable_architectures]).to include(error)
        end
      end

      context 'with architecturable_architectures' do
        subject(:encoder_instance) {
          FactoryGirl.build(
              :metasploit_cache_encoder_instance,
              architecturable_architecture_count: 1
          )
        }

        it 'does not adds error on #architcturable_architectures' do
          encoder_instance.valid?

          expect(encoder_instance.errors[:architecturable_architectures]).not_to include(error)
        end
      end
    end
  end
end