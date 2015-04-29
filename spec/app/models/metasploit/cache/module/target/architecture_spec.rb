RSpec.describe Metasploit::Cache::Module::Target::Architecture do
  context 'associations' do
    it { should belong_to(:architecture).class_name('Metasploit::Cache::Architecture') }
    it { should belong_to(:module_target).class_name('Metasploit::Cache::Module::Target') }
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:architecture_id).of_type(:integer).with_options(null: false) }
      it { should have_db_column(:module_target_id).of_type(:integer).with_options(null: false) }
    end

    context 'indices' do
      it { should have_db_index([:module_target_id, :architecture_id]).unique(true) }
    end
  end

  context 'factories' do
    context :metasploit_cache_module_target_architecture do
      subject(:metasploit_cache_module_target_architecture) do
        FactoryGirl.build(:metasploit_cache_module_target_architecture)
      end

      it { should be_valid }

      context '#module_target' do
        subject(:module_target) do
          metasploit_cache_module_target_architecture.module_target
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

        context '#target_architectures' do
          subject(:target_architectures) do
            module_target.target_architectures
          end

          it 'has one' do
            expect(target_architectures.length).to eq(1)
          end

          it "should include #{:metasploit_cache_module_target_architecture}" do
            expect(target_architectures).to include metasploit_cache_module_target_architecture
          end
        end
      end
    end
  end

  context 'validations' do
    it { should validate_presence_of :architecture }
    it { should validate_presence_of :module_target }

    context 'validates uniqueness of architecture_id scoped to module_target_id' do
      #
      # lets
      #

      let(:architecture) do
        existing_module_target_architecture.architecture
      end

      let(:error) do
        I18n.translate!('metasploit.model.errors.messages.taken')
      end

      let(:module_target) do
        existing_module_target_architecture.module_target
      end

      let(:new_module_target_architecture) do
        # have to construct with target_architectures.build as assigning with factory will trigger a save when
        # target architecture is << to target.target_architectures and target is already saved.
        module_target.target_architectures.build(
            new_module_target_architecture_attributes
        ).tap { |target_architecture|
          target_architecture.architecture = architecture
        }
      end

      let(:new_module_target_architecture_attributes) do
        FactoryGirl.attributes_for(
            :metasploit_cache_module_target_architecture,
            # don't want factory building these attributes, but also don't want them in hash as they can't be
            # mass-assigned
            architecture: nil,
            module_target: nil
        ).except(
            :architecture,
            :module_target
        )
      end

      #
      # let!s
      #

      let!(:existing_module_target_architecture) do
        FactoryGirl.create(:metasploit_cache_module_target_architecture)
      end

      context 'with batched' do
        include Metasploit::Cache::Spec::Matcher
        include_context 'Metasploit::Cache::Batch.batch'

        it 'should include error' do
          new_module_target_architecture.valid?

          expect(new_module_target_architecture.errors[:architecture_id]).not_to include(error)
        end

        it 'should raise ActiveRecord::RecordNotUnique when saved' do
          expect {
            new_module_target_architecture.save
          }.to raise_record_not_unique
        end
      end

      context 'without batched' do
        it 'should include error' do
          new_module_target_architecture.valid?

          expect(new_module_target_architecture.errors[:architecture_id]).to include(error)
        end
      end
    end
  end
end