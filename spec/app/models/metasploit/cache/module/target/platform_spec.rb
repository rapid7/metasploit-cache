RSpec.describe Metasploit::Cache::Module::Target::Platform do
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

  context 'factories' do
    context :metasploit_cache_module_target_platform do
      subject(:metasploit_cache_module_target_platform) do
        FactoryGirl.build(:metasploit_cache_module_target_platform)
      end

      it { should be_valid }

      context '#module_target' do
        subject(:module_target) do
          metasploit_cache_module_target_platform.module_target
        end

        it { should be_valid }

        context '#module_instance' do
          subject(:module_instance) do
            module_target.module_instance
          end

          it { should be_valid }

          context '#targets' do
            subject(:targets) do
              module_instance.targets
            end

            it 'has one' do
              expect(targets.length).to eq(1)
            end

            it 'should include #module_target' do
              expect(targets).to include module_target
            end
          end
        end

        context '#target_platforms' do
          subject(:target_platforms) do
            module_target.target_platforms
          end

          it 'has one' do
            expect(target_platforms.length).to eq(1)
          end

          it "should include #{:metasploit_cache_module_target_platform}" do
            expect(target_platforms).to include send(:metasploit_cache_module_target_platform)
          end
        end
      end
    end
  end

  context 'validations' do
    it { should validate_presence_of :module_target }
    it { should validate_presence_of :platform }

    context 'validates uniqueness of platform_id scoped to module_target_id' do
      #
      # lets
      #

      let(:error) do
        I18n.translate!('errors.messages.taken')
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
        include Metasploit::Cache::Spec::Matcher
        include_context 'Metasploit::Cache::Batch.batch'

        it 'should include error' do
          new_module_target_platform.valid?

          expect(new_module_target_platform.errors[:platform_id]).not_to include(error)
        end

        it 'should raise ActiveRecord::RecordNotUnique when saved' do
          expect {
            new_module_target_platform.save
          }.to raise_record_not_unique
        end
      end

      context 'with batched' do
        it 'should include error' do
          new_module_target_platform.valid?

          expect(new_module_target_platform.errors[:platform_id]).to include(error)
        end
      end
    end
  end
end