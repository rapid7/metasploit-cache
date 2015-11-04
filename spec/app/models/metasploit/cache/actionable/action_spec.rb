RSpec.describe Metasploit::Cache::Actionable::Action, type: :model do
  it_should_behave_like 'Metasploit::Concern.run'

  context 'associations' do
    it { is_expected.to belong_to(:actionable) }
  end

  context 'database' do
    context 'columns' do
      it { is_expected.to have_db_column(:actionable_id).of_type(:integer).with_options(null: false) }
      it { is_expected.to have_db_column(:actionable_type).of_type(:string).with_options(null: false) }
      it { is_expected.to have_db_column(:name).of_type(:string).with_options(null: false) }
    end

    context 'indices' do
      it { is_expected.to have_db_index([:actionable_type, :actionable_id, :name]).unique(true) }
    end
  end

  context 'factories' do
    context 'metapsloit_cache_actionable_action' do
      subject(:metasploit_cache_actionable_action) {
        FactoryGirl.build(:metasploit_cache_actionable_action)
      }

      it { is_expected.not_to be_valid }

      it 'has nil #actioanble' do
        expect(metasploit_cache_actionable_action.actionable).to be_nil
      end
    end
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :actionable }

    context 'validates uniqueness of name scoped to (actionable_type, actionable_id)' do
      #
      # lets
      #

      let(:error) do
        I18n.translate!('errors.messages.taken')
      end

      let(:existing_name) {
        'Existing Action'
      }

      #
      # let!s
      #

      let!(:existing_actionable) {
        FactoryGirl.create(
            :metasploit_cache_auxiliary_instance
        )
      }

      let!(:existing_actionable_action) {
        FactoryGirl.create(
            :metasploit_cache_actionable_action,
            actionable: existing_actionable,
            name: existing_name
        )
      }

      context 'with same #actionable_type' do
        context 'with same #actionable_id' do
          context 'with same #name' do
            let(:new_actionable_action) {
              FactoryGirl.build(
                  :metasploit_cache_actionable_action,
                  actionable: existing_actionable,
                  name: existing_name
              )
            }

            context 'with batched' do
              include Metasploit::Cache::Spec::Matcher
              include_context 'Metasploit::Cache::Batch.batch'

              it 'does not add error on #name' do
                new_actionable_action.valid?

                expect(new_actionable_action.errors[:name]).not_to include(error)
              end

              it 'raises ActiveRecord::RecordNotUnique when saved' do
                expect {
                  new_actionable_action.save
                }.to raise_record_not_unique
              end
            end

            context 'without batched' do
              it 'adds error on #name' do
                new_actionable_action.valid?

                expect(new_actionable_action.errors[:name]).to include(error)
              end
            end
          end

          context 'with different #name' do
            let(:new_actionable_action) {
              FactoryGirl.build(
                  :metasploit_cache_actionable_action,
                  actionable: existing_actionable
              )
            }

            it 'does not add error on #name' do
              new_actionable_action.valid?

              expect(new_actionable_action.errors[:name]).not_to include(error)
            end
          end
        end

        context 'with different #actionable_id' do
          let!(:new_actionable) {
            FactoryGirl.build(
                :metasploit_cache_actionable_action,
                actionable: FactoryGirl.build(:metasploit_cache_auxiliary_instance)
            )
          }

          context 'with same #name' do
            let(:new_actionable_action) {
              FactoryGirl.build(
                  :metasploit_cache_actionable_action,
                  actionable: new_actionable,
                  name: existing_name
              )
            }

            it 'does not add error on #name' do
              new_actionable_action.valid?

              expect(new_actionable_action.errors[:name]).not_to include(error)
            end
          end

          context 'with different #name' do
            let(:new_actionable_action) {
              FactoryGirl.build(
                  :metasploit_cache_actionable_action,
                  actionable: new_actionable
              )
            }

            it 'does not add error on #name' do
              new_actionable_action.valid?

              expect(new_actionable_action.errors[:name]).not_to include(error)
            end
          end
        end
      end
    end
  end
end