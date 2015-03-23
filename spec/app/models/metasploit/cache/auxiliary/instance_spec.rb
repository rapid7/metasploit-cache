RSpec.describe Metasploit::Cache::Auxiliary::Instance, type: :model do
  context 'associations' do
    it { is_expected.to belong_to(:auxiliary_class).class_name('Metasploit::Cache::Auxiliary::Class').inverse_of(:auxiliary_instance) }
    it { is_expected.to have_many(:actions).class_name('Metasploit::Cache::Actionable::Action').inverse_of(:actionable) }
  end

  context 'database' do
    context 'columns' do
      it { is_expected.to have_db_column(:auxiliary_class_id).of_type(:integer).with_options(null: false) }
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
    end
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:auxiliary_class) }

    # validate_lenght_of from shoulda-matchers assumes attribute is String and doesn't work on associations
    context 'validates length of actions is at least 1' do
      let(:error) {
        I18n.translate!('activerecord.errors.models.metasploit/cache/auxiliary/instance.attributes.actions.too_short')
      }

      context 'without actions' do
        subject(:auxiliary_instance) {
          FactoryGirl.build(
              :metasploit_cache_auxiliary_instance,
              actions: []
          )
        }

        it 'adds error on #actions' do
          auxiliary_instance.valid?

          expect(auxiliary_instance.errors[:actions]).to include(error)
        end
      end

      context 'with actions' do
        subject(:auxiliary_instance) {
          FactoryGirl.build(
              :metasploit_cache_auxiliary_instance,
              actions: []
          ).tap { |actionable|
            actionable.actions << FactoryGirl.build(
                :metasploit_cache_auxiliary_action,
                actionable: actionable
            )
          }
        }

        it 'does not adds error on #actions' do
          auxiliary_instance.valid?

          expect(auxiliary_instance.errors[:actions]).not_to include(error)
        end
      end
    end
  end
end