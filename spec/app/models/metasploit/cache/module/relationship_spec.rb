RSpec.describe Metasploit::Cache::Module::Relationship do
  context 'associations' do
    it { should belong_to(:ancestor).class_name('Metasploit::Cache::Module::Ancestor') }
    it { should belong_to(:descendant).class_name('Metasploit::Cache::Module::Class') }
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:ancestor_id).of_type(:integer).with_options(:null => false) }
      it { should have_db_column(:descendant_id).of_type(:integer).with_options(:null => false) }
    end

    context 'indices' do
      it { should have_db_index([:descendant_id, :ancestor_id]).unique(true) }
    end
  end

  context 'factories' do
    context 'metasploit_cache_module_relationship' do
      subject(:metasploit_cache_module_relationship) do
        FactoryGirl.build(:metasploit_cache_module_relationship)
      end

      it { should be_valid }
    end
  end

  context 'validations' do
    it { should validate_presence_of :ancestor }

    # Can't use validate_uniqueness_of(:ancestor_id).scoped_to(:descendant_id) because it will attempt to
    # INSERT with NULL descendant_id, which is invalid.
    context 'validate uniqueness of ancestor_id scoped to descendant_id' do
      let(:existing_descendant) do
        FactoryGirl.create(:metasploit_cache_module_class)
        end

      let(:existing_ancestor) do
        FactoryGirl.create(existing_ancestor_factory)
      end

      let(:existing_ancestor_factory) {
        FactoryGirl.generate :metasploit_cache_module_ancestor_factory
      }

      let!(:existing_relationship) do
        FactoryGirl.create(
            :metasploit_cache_module_relationship,
            :ancestor => existing_ancestor,
            :descendant => existing_descendant
        )
      end

      context 'with same descendant_id' do
        subject(:new_relationship) do
          FactoryGirl.build(
              :metasploit_cache_module_relationship,
              :ancestor => existing_ancestor,
              :descendant => existing_descendant
          )
        end

        let(:error) {
          I18n.translate!('errors.messages.taken')
        }

        context 'with batched' do
          include Metasploit::Cache::Spec::Matcher
          include_context 'Metasploit::Cache::Batch.batch'

          it 'should not add error on #ancestor_id' do
            new_relationship.valid?

            expect(new_relationship.errors[:ancestor_id]).not_to include(error)
          end

          it 'should raise ActiveRecord::RecordNotUnique when saved' do
            expect {
              new_relationship.save
            }.to raise_record_not_unique
          end
        end

        context 'without batched' do
          it 'should record error on ancestor_id' do
            new_relationship.valid?

            expect(new_relationship.errors[:ancestor_id]).to include(error)
          end
        end
      end

      context 'without same descendant_id' do
        subject(:new_relationship) do
          FactoryGirl.build(
              :metasploit_cache_module_relationship,
              :ancestor => existing_ancestor,
              :descendant => new_descendant
          )
        end

        let(:new_descendant) do
          FactoryGirl.create :metasploit_cache_module_class
        end

        it { should be_valid }
      end
    end

    it { should validate_presence_of :descendant }
  end
end