require 'spec_helper'

RSpec.describe Metasploit::Cache::Module::Target::Platform do
  it_should_behave_like 'Metasploit::Cache::Module::Target::Platform',
                        namespace_name: 'Metasploit::Cache'

  context 'associations' do
    it { should belong_to(:module_target).class_name('Metasploit::Cache::Module::Target') }
    it { should belong_to(:platform).class_name('Metasploit::Cache::Platform') }
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:module_target_id).of_type(:integer).with_options(null: false) }
      it { should have_db_column(:platform_id).of_type(:integer).with_options(null: false) }
    end

    context 'indices' do
      it { should have_db_index([:module_target_id, :platform_id]).unique(true) }
    end
  end

  context 'validations' do
    context 'validates uniqueness of platform_id scoped to module_target_id' do
      #
      # lets
      #

      let(:error) do
        I18n.translate!('metasploit.model.errors.messages.taken')
      end

      let(:module_target) do
        existing_module_target_platform.module_target
      end

      let(:platform) do
        existing_module_target_platform.platform
      end

      let(:new_module_target_platform) do
        module_target.target_platforms.build(
            new_module_target_platform_attributes
        ).tap { |target_platform|
          target_platform.platform = platform
        }
      end

      let(:new_module_target_platform_attributes) do
        FactoryGirl.attributes_for(
            :metasploit_cache_module_target_platform,
            module_target: nil,
            platform: nil
        ).except(
            :module_target,
            :platform
        )
      end

      #
      # let!s
      #

      let!(:existing_module_target_platform) do
        FactoryGirl.create(:metasploit_cache_module_target_platform)
      end

      context 'with batched' do
        include_context 'Metasploit::Cache::Batch.batch'

        it 'should include error' do
          new_module_target_platform.valid?

          expect(new_module_target_platform.errors[:platform_id]).not_to include(error)
        end

        it 'should raise ActiveRecord::RecordNotUnique when saved' do
          expect {
            new_module_target_platform.save
          }.to raise_error(ActiveRecord::RecordNotUnique)
        end
      end

      context 'with batched' do
        it 'should include error' do
          new_module_target_platform.valid?

          expect(new_module_target_platform.errors[:platform_id]).to include('has already been taken')
        end
      end
    end
  end
end