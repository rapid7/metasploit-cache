require 'spec_helper'

RSpec.describe Metasploit::Cache::Module::Target do
  it_should_behave_like 'Metasploit::Cache::Module::Target',
                        namespace_name: 'Metasploit::Cache'

  context 'associations' do
    it { should have_many(:architectures).class_name('Metasploit::Cache::Architecture').through(:target_architectures) }
    it { should belong_to(:module_instance).class_name('Metasploit::Cache::Module::Instance') }
    it { should have_many(:platforms).class_name('Metasploit::Cache::Platform').through(:target_platforms) }
    it { should have_many(:target_architectures).class_name('Metasploit::Cache::Module::Target::Architecture').dependent(:destroy) }
    it { should have_many(:target_platforms).class_name('Metasploit::Cache::Module::Target::Platform').dependent(:destroy) }
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

  context 'mass assignment security' do
    it { should_not allow_mass_assignment_of(:module_instance_id) }
  end

  context 'validations' do
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
            I18n.translate!('metasploit.model.errors.messages.taken')
          end

          let(:new_architecture) do
            FactoryGirl.generate :metasploit_cache_architecture
          end

          let(:new_platform) do
            FactoryGirl.generate :metasploit_cache_platform
          end

          let(:new_module_target) do
            existing_module_instance.targets.build(
                index: existing_module_target.index + 1,
                name: existing_module_target.name
            ).tap { |module_target|
              module_target.target_architectures.build.tap { |target_architecture|
                target_architecture.architecture = new_architecture
              }

              module_target.target_platforms.build.tap { |target_platform|
                target_platform.platform = new_platform
              }
            }
          end

          context 'with batched' do
            include_context 'Metasploit::Cache::Batch.batch'

            it 'should not add error on #name' do
              new_module_target.valid?

              expect(new_module_target.errors[:name]).not_to include(error)
            end

            it 'should raise ActiveRecord::RecordNotUnique when saved' do
              expect {
                new_module_target.save
              }.to raise_error(ActiveRecord::RecordNotUnique)
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