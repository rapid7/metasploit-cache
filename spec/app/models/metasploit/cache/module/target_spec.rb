RSpec.describe Metasploit::Cache::Module::Target do
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
    context :metasploit_cache_module_target do
      subject(:metasploit_cache_module_target) do
        FactoryGirl.build(:metasploit_cache_module_target)
      end

      it { should be_valid }
    end
  end

  context 'search' do
    let(:base_class) {
      Metasploit::Cache::Module::Target
    }

    context 'attributes' do
      it_should_behave_like 'search_attribute', :name, :type => :string
    end
  end

  context 'validations' do
    it { should validate_presence_of(:module_instance) }
    it { should validate_presence_of(:name) }

    context 'validates uniqueness of #name scoped to #module_instance_id' do
      #
      # lets
      #

      let(:existing_module_instance) do
        existing_module_target.module_instance
      end

      #
      # let!s
      #

      let!(:existing_module_target) do
        FactoryGirl.create(:metasploit_cache_module_target)
      end

      context 'with same #module_instance_id' do
        context 'with same #name' do
          let(:error) do
            I18n.translate!('errors.messages.taken')
          end

          let(:new_architecture) do
            FactoryGirl.generate :metasploit_cache_architecture
          end

          let(:new_module_target) do
            existing_module_instance.targets.build(
                index: existing_module_target.index + 1,
                name: existing_module_target.name
            )
          end

          context 'with batched' do
            include Metasploit::Cache::Spec::Matcher
            include_context 'Metasploit::Cache::Batch.batch'

            it 'should not add error on #name' do
              new_module_target.valid?

              expect(new_module_target.errors[:name]).not_to include(error)
            end

            it 'should raise ActiveRecord::RecordNotUnique when saved' do
              expect {
                new_module_target.save
              }.to raise_record_not_unique
            end
          end

          context 'without batched' do
            it 'should add error on #name' do
              new_module_target.valid?

              expect(new_module_target.errors[:name]).to include(error)
            end
          end
        end
      end
    end
  end
end