require 'spec_helper'

RSpec.describe Metasploit::Cache::Module::Author do
  it_should_behave_like 'Metasploit::Cache::Module::Author',
                        namespace_name: 'Metasploit::Cache'

  context 'associations' do
    it { should belong_to(:author).class_name('Metasploit::Cache::Author') }
    it { should belong_to(:email_address).class_name('Metasploit::Cache::EmailAddress') }
    it { should belong_to(:module_instance).class_name('Metasploit::Cache::Module::Instance') }
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:author_id).of_type(:integer).with_options(:null => false) }
      it { should have_db_column(:email_address_id).of_type(:integer).with_options(:null => true) }
      it { should have_db_column(:module_instance_id).of_type(:integer).with_options(:null => false) }
    end

    context 'indices' do
      context 'foreign key' do
        it { should have_db_index(:author_id) }
        it { should have_db_index(:email_address_id) }
        it { should have_db_index(:module_instance_id) }
      end

      context 'unique' do
        it { should have_db_index([:module_instance_id, :author_id]).unique(true) }
      end
    end
  end

  context 'validations' do
    context 'validates uniqueness of #author_id scoped to #module_instance_id' do
      let(:error) do
        I18n.translate!('metasploit.model.errors.messages.taken')
      end

      let(:existing_author) do
        existing_module_author.author
      end

      let(:existing_module_author) do
        existing_module_instance.module_authors.first
      end

      let(:existing_module_instance) do
        FactoryGirl.create(
            :metasploit_cache_module_instance,
            module_authors_length: 1
        )
      end

      before(:each) do
        existing_module_instance.save
      end

      context 'with batched' do
        include_context 'Metasploit::Cache::Batch.batch'

        context 'with same #module_instance_id' do
          context 'with same #author_id' do
            let(:new_module_author) do
              existing_module_instance.module_authors.build.tap { |module_author|
                module_author.author = existing_author
              }
            end

            it 'should not add error on #author_id' do
              new_module_author.valid?

              expect(new_module_author.errors[:author_id]).not_to include(error)
            end

            it 'should raise ActiveRecord::RecordNotUnique when saved' do
              expect {
                new_module_author.save
              }.to raise_error(ActiveRecord::RecordNotUnique)
            end
          end
        end
      end

      context 'without batched' do
        context 'with same #module_instance_id' do
          context 'with same #author_id' do
            let(:new_module_author) do
              existing_module_instance.module_authors.build.tap { |module_author|
                module_author.author = existing_author
              }
            end

            it 'should add error on #author_id' do
              new_module_author.valid?

              expect(new_module_author.errors[:author_id]).to include(error)
            end
          end
        end
      end
    end
  end
end