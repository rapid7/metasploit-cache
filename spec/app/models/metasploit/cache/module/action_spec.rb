RSpec.describe Metasploit::Cache::Module::Action do
  context 'associations' do
    it { should belong_to(:module_instance).class_name('Metasploit::Cache::Module::Instance') }
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:module_instance_id).of_type(:integer).with_options(:null => false) }
      it { should have_db_column(:name).of_type(:text).with_options(:null => false) }
    end

    context 'indices' do
      it { should have_db_index([:module_instance_id, :name]).unique(true) }
    end
  end

  context 'factories' do
    context :metasploit_cache_module_action do
      subject(:metasploit_cache_module_action) do
        FactoryGirl.build(:metasploit_cache_module_action)
      end

      it { should be_valid }
    end
  end

  context 'mass assignment security' do
    it { should_not allow_mass_assignment_of(:module_instance_id) }
    it { should allow_mass_assignment_of(:name) }
  end

  context 'search' do
    let(:base_class) {
      Metasploit::Cache::Module::Action
    }

    context 'attributes' do
      it_should_behave_like 'search_attribute', :name, :type => :string
    end
  end

  context 'validations' do
    it { should validate_presence_of(:module_instance) }
    it { should validate_presence_of(:name) }

    context 'validates uniqueness of name scoped to module_instance_id' do
      #
      # lets
      #

      let(:error) do
        I18n.translate!('metasploit.model.errors.messages.taken')
      end

      let(:existing_module_action) do
        existing_module_instance.actions.first
      end

      let(:existing_module_class) do
        FactoryGirl.create(
            :metasploit_cache_module_class,
            module_type: module_type
        )
      end

      let(:existing_module_instance) do
        FactoryGirl.build(
            :metasploit_cache_module_instance,
            module_class: existing_module_class,
            actions_length: 0
        ).tap { |module_instance|
          action = module_instance.actions.build(
              name: existing_name
          )
          module_instance.default_action = action
        }
      end

      let(:existing_name) do
        FactoryGirl.generate :metasploit_cache_module_action_name
      end

      let(:module_type) do
        module_types.sample
      end

      let(:module_types) do
        Metasploit::Cache::Module::Instance.module_types_that_allow(:actions)
      end

      #
      # Callbacks
      #

      before(:each) do
        existing_module_instance.save!
      end

      context 'with batched' do
        include_context 'Metasploit::Cache::Batch.batch'

        context 'with same #module_instance_id' do
          context 'with same #name' do
            let(:new_module_action) do
              existing_module_instance.actions.build(
                  name: existing_module_action.name
              )
            end

            it 'does not add error on name' do
              new_module_action.valid?

              expect(new_module_action.errors[:name]).not_to include(error)
            end

            it 'raises ActiveRecord::RecordNotUnique when saved' do
              expect {
                new_module_action.save
              }.to raise_error(ActiveRecord::RecordNotUnique)
            end
          end

          context 'without same #name' do
            let(:new_module_action) do
              existing_module_instance.actions.build(
                  name: new_name
              )
            end

            let(:new_name) do
              FactoryGirl.generate :metasploit_cache_module_action_name
            end

            it 'does not add error on name' do
              new_module_action.valid?

              expect(new_module_action.errors[:name]).not_to include(error)
            end

            it 'does not raise ActiveRecord::RecordNotUnique when saved' do
              expect {
                new_module_action.save
              }.not_to raise_error
            end
          end
        end

        context 'without same #module_instance_id' do
          #
          # lets
          #

          let(:second_module_class) do
            FactoryGirl.create(
                :metasploit_cache_module_class,
                module_type: module_type
            )
          end

          let(:second_module_instance) do
            FactoryGirl.build(
                :metasploit_cache_module_instance,
                module_class: second_module_class,
                actions_length: 1
            )
          end

          #
          # Callbacks
          #

          before(:each) do
            second_module_instance.save!
          end

          context 'with same #name' do
            let(:new_module_action) do
              second_module_instance.actions.build(
                  name: existing_module_action.name
              )
            end

            it 'should not add error on name' do
              new_module_action.valid?

              expect(new_module_action.errors[:name]).not_to include(error)
            end

            it 'should not raise ActiveRecord::RecordNotUnique when saved' do
              expect {
                new_module_action.save
              }.not_to raise_error
            end
          end

          context 'without same #name' do
            let(:new_module_action) do
              second_module_instance.actions.build(
                  name: new_name
              )
            end

            let(:new_name) do
              FactoryGirl.generate :metasploit_cache_module_action_name
            end

            it 'should not add error on name' do
              new_module_action.valid?

              expect(new_module_action.errors[:name]).not_to include(error)
            end

            it 'should not raise ActiveRecord::RecordNotUnique when saved' do
              expect {
                new_module_action.save
              }.not_to raise_error
            end
          end
        end
      end

      context 'without batched' do
        context 'with same #module_instance_id' do
          context 'with same #name' do
            let(:new_module_action) do
              existing_module_instance.actions.build(
                  name: existing_module_action.name
              )
            end

            it 'adds error on name' do
              new_module_action.valid?

              expect(new_module_action.errors[:name]).to include(error)
            end
          end

          context 'without same #name' do
            let(:new_module_action) do
              existing_module_instance.actions.build(
                  name: new_name
              )
            end

            let(:new_name) do
              FactoryGirl.generate :metasploit_cache_module_action_name
            end

            it 'does not add error on name' do
              new_module_action.valid?

              expect(new_module_action.errors[:name]).not_to include(error)
            end
          end
        end

        context 'without same #module_instance_id' do
          #
          # lets
          #

          let(:second_module_class) do
            FactoryGirl.create(
                :metasploit_cache_module_class,
                module_type: module_type
            )
          end

          let(:second_module_instance) do
            FactoryGirl.build(
                :metasploit_cache_module_instance,
                module_class: second_module_class,
                actions_length: 1
            )
          end

          #
          # Callbacks
          #

          before(:each) do
            begin
              second_module_instance.save!
            rescue ActiveRecord::RecordInvalid => error
              raise
            end
          end

          context 'with same #name' do
            let(:new_module_action) do
              second_module_instance.actions.build(
                  name: existing_module_action.name
              )
            end

            it 'should not add error on name' do
              new_module_action.valid?

              expect(new_module_action.errors[:name]).not_to include(error)
            end
          end

          context 'without same #name' do
            let(:new_module_action) do
              second_module_instance.actions.build(
                  name: new_name
              )
            end

            let(:new_name) do
              FactoryGirl.generate :metasploit_cache_module_action_name
            end

            it 'should not add error on name' do
              new_module_action.valid?

              expect(new_module_action.errors[:name]).not_to include(error)
            end
          end
        end
      end
    end
  end
end