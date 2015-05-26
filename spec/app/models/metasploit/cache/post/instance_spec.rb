RSpec.describe Metasploit::Cache::Post::Instance do
  it_should_behave_like 'Metasploit::Concern.run'

  context 'associations' do
    it { is_expected.to have_many(:actions).class_name('Metasploit::Cache::Actionable::Action').inverse_of(:actionable) }
    it { is_expected.to belong_to(:default_action).class_name('Metasploit::Cache::Actionable::Action').inverse_of(:actionable) }
    it { is_expected.to have_many(:licensable_licenses).class_name('Metasploit::Cache::Licensable::License')}
    it { is_expected.to have_many(:licenses).class_name('Metasploit::Cache::License')}
    it { is_expected.to belong_to(:post_class).class_name('Metasploit::Cache::Post::Class').inverse_of(:post_instance) }
  end

  context 'database' do
    context 'columns' do
      it { is_expected.to have_db_column(:default_action_id).of_type(:integer).with_options(null: true) }
      it { is_expected.to have_db_column(:description).of_type(:text).with_options(null: false) }
      it { is_expected.to have_db_column(:disclosed_on).of_type(:date).with_options(null: false) }
      it { is_expected.to have_db_column(:name).of_type(:string).with_options(null: false) }
      it { is_expected.to have_db_column(:post_class_id).of_type(:integer).with_options(null: false) }
      it { is_expected.to have_db_column(:privileged).of_type(:boolean).with_options(null: false) }
    end

    context 'indices' do
      it { is_expected.to have_db_index(:default_action_id).unique(true) }
      it { is_expected.to have_db_index(:post_class_id).unique(true) }
    end
  end

  context 'factories' do
    context 'metasploit_cache_post_instance' do
      subject(:metasploit_cache_post_instance) {
        FactoryGirl.build(:metasploit_cache_post_instance)
      }

      it { is_expected.to be_valid }
    end
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :description }
    it { is_expected.to validate_presence_of :disclosed_on }
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :post_class }
    it { is_expected.to validate_inclusion_of(:privileged).in_array([false, true]) }

    context 'validates inclusion of #default_action in #actions' do
      subject(:default_action_errors) {
        post_instance.errors[:default_action]
      }

      let(:error) {
        I18n.translate!('activerecord.errors.models.metasploit/cache/post/instance.attributes.default_action.inclusion')
      }

      let(:post_instance) {
        described_class.new
      }

      context 'without #default_action' do
        before(:each) do
          post_instance.default_action = nil
        end

        it { is_expected.not_to include(error) }
      end

      context 'with #default_action' do
        #
        # lets
        #

        let(:default_action) {
          Metasploit::Cache::Actionable::Action.new
        }

        #
        # Callbacks
        #

        before(:each) do
          post_instance.default_action = default_action
        end

        context 'in #actions' do
          before(:each) do
            post_instance.actions = [
                default_action
            ]
            post_instance.valid?
          end

          it { is_expected.not_to include(error) }
        end

        context 'not in #actions' do
          before(:each) do
            post_instance.actions = []
            post_instance.valid?
          end

          it { is_expected.to include(error) }
        end
      end
    end

    context "validate that there is at least one license per post" do
      let(:error){
        I18n.translate!(
            'activerecord.errors.models.metasploit/cache/post/instance.attributes.licensable_licenses.too_short',
            count: 1
        )
      }

      context "without licensable licenses" do
        subject(:post_instance){
          FactoryGirl.build(:metasploit_cache_post_instance, licenses_count: 0)
        }

        it "adds error on #licensable_licenses" do
          post_instance.valid?

          expect(post_instance.errors[:licensable_licenses]).to include(error)
        end
      end

      context "with licensable licenses" do
        subject(:post_instance){
          FactoryGirl.build(:metasploit_cache_post_instance, licenses_count: 1)
        }

        it "does not add error on #licensable_licenses" do
          post_instance.valid?

          expect(post_instance.errors[:licensable_licenses]).to_not include(error)
        end
      end
    end
    
    # validate_uniqueness_of needs a pre-existing record of the same class to work correctly when the `null: false`
    # constraints exist for other fields.
    context 'with existing record' do
      let!(:existing_post_instance) {
        FactoryGirl.create(
            :metasploit_cache_post_instance
        )
      }

      it { is_expected.to validate_uniqueness_of :post_class_id }
    end
  end
end