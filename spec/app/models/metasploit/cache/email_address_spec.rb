require 'spec_helper'

RSpec.describe Metasploit::Cache::EmailAddress do
  it_should_behave_like 'Metasploit::Cache::EmailAddress',
                        namespace_name: 'Metasploit::Cache' do
    include_context 'ActiveRecord attribute_type'
  end

  context 'associations' do
    it { should have_many(:module_authors).class_name('Metasploit::Cache::Module::Author').dependent(:destroy) }
    it { should have_many(:module_instances).class_name('Metasploit::Cache::Module::Instance').through(:module_authors) }
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:domain).of_type(:string).with_options(:null => false) }
      it { should have_db_column(:local).of_type(:string).with_options(:null => false) }
    end

    context 'indices' do
      it { should have_db_index(:domain) }
      it { should have_db_index(:local) }
      it { should have_db_index([:domain, :local]).unique(true) }
    end
  end

  context 'validations' do
    #
    # lets
    #

    let(:error) do
      I18n.translate!('metasploit.model.errors.messages.taken')
    end

    let(:existing_domain) do
      FactoryGirl.generate :metasploit_cache_email_address_domain
    end

    let(:existing_local) do
      FactoryGirl.generate :metasploit_cache_email_address_local
    end

    #
    # let!s
    #

    let!(:existing_email_address) do
      FactoryGirl.create(
          :metasploit_cache_email_address,
          :domain => existing_domain,
          :local => existing_local
      )
    end

    context 'validate uniqueness of #full' do
      context 'with same #full' do
        subject(:new_email_address) do
          FactoryGirl.build(
              :metasploit_cache_email_address,
              domain: nil,
              local: nil
          )
        end

        before(:each) do
          new_email_address.full = existing_email_address.full
        end

        context 'with batched' do
          include_context 'Metasploit::Cache::Batch.batch'

          it 'should not add error on local' do
            new_email_address.valid?

            expect(new_email_address.errors[:full]).not_to include(error)
          end

          it 'should raise ActiveRecord::RecordNotUnique when saved' do
            expect {
              new_email_address.save
            }.to raise_error(ActiveRecord::RecordNotUnique)
          end
        end

        context 'without batched' do
          it 'should record error on local' do
            new_email_address.valid?

            expect(new_email_address.errors[:full]).to include(error)
          end
        end
      end
    end

    # Can't use validate_uniqueness_of(:local).scoped_to(:domain) because it will attempt to
    # INSERT with NULL domain, which is invalid.
    context 'validate uniqueness of domain scoped to local' do
      context 'with same domain' do
        subject(:new_email_address) do
          FactoryGirl.build(
              :metasploit_cache_email_address,
              :domain => existing_domain,
              :local => existing_local
          )
        end

        context 'with batched' do
          include_context 'Metasploit::Cache::Batch.batch'

          it 'should not add error on local' do
            new_email_address.valid?

            expect(new_email_address.errors[:local]).not_to include(error)
          end

          it 'should raise ActiveRecord::RecordNotUnique when saved' do
            expect {
              new_email_address.save
            }.to raise_error(ActiveRecord::RecordNotUnique)
          end
        end

        context 'without batched' do
          it 'should record error on local' do
            new_email_address.valid?

            expect(new_email_address.errors[:local]).to include(error)
          end
        end
      end

      context 'without same domain' do
        subject(:new_email_address) do
          FactoryGirl.build(
              :metasploit_cache_email_address,
              :domain => new_domain,
              :local => existing_local
          )
        end

        let(:new_domain) do
          FactoryGirl.generate :metasploit_cache_email_address_domain
        end

        it { should be_valid }
      end
    end
  end
end