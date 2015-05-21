RSpec.describe Metasploit::Cache::Encoder::Instance do
  it_should_behave_like 'Metasploit::Concern.run'

  context 'associations' do
    it { is_expected.to belong_to(:encoder_class).class_name('Metasploit::Cache::Encoder::Class').inverse_of(:encoder_instance) }
    it { is_expected.to have_many(:licensable_licenses).class_name('Metasploit::Cache::Licensable::License')}
    it { is_expected.to have_many(:licenses).class_name('Metasploit::Cache::License')}
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

    context "validate that there is at least one license per encoder" do
      let(:error){
        I18n.translate!(
            'activerecord.errors.models.metasploit/cache/encoder/instance.attributes.licensable_licenses.too_short',
            count: 1
        )
      }

      context "without licensable licenses" do
        subject(:encoder_instance){
          FactoryGirl.build(:metasploit_cache_encoder_instance, licenses_count: 0)
        }

        it "adds error on #licensable_licenses" do
          encoder_instance.valid?

          expect(encoder_instance.errors[:licensable_licenses]).to include(error)
        end
      end

      context "with licensable licenses" do
        subject(:encoder_instance){
          FactoryGirl.build(:metasploit_cache_encoder_instance, licenses_count: 1)
        }

        it "does not add error on #licensable_licenses" do
          encoder_instance.valid?

          expect(encoder_instance.errors[:licensable_licenses]).to_not include(error)
        end
      end

    end
  end
end