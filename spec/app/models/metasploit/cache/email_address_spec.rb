RSpec.describe Metasploit::Cache::EmailAddress do
  subject(:email_address) {
    FactoryGirl.build(:metasploit_cache_email_address)
  }

  context 'associations' do
    it { is_expected.to have_many(:contributions).class_name('Metasploit::Cache::Contributions').dependent(:destroy) }
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

  context 'derivations' do
    include_context 'ActiveRecord attribute_type'

    let(:base_class) {
      Metasploit::Cache::EmailAddress
    }

    context 'with #full derived' do
      before(:each) do
        email_address.full = email_address.derived_full
      end

      it_should_behave_like 'derives', :domain, :validates => true
      it_should_behave_like 'derives', :local, :validates => true
    end

    it_should_behave_like 'derives', :full, :validates => true
  end

  context 'factories' do
    context :metasploit_cache_email_address do
      subject(:metasploit_cache_email_address) do
        FactoryGirl.build(:metasploit_cache_email_address)
      end

      it { should be_valid }
    end
  end

  context 'mass assignment security' do
    it { should allow_mass_assignment_of(:domain) }
    it { should allow_mass_assignment_of(:full) }
    it { should allow_mass_assignment_of(:local) }
  end

  context 'search' do
    let(:base_class) {
      Metasploit::Cache::EmailAddress
    }

    context 'attributes' do
      it_should_behave_like 'search_attribute', :domain, :type => :string
      it_should_behave_like 'search_attribute', :full, :type => :string
      it_should_behave_like 'search_attribute', :local, :type => :string
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

    it { should validate_presence_of :domain }

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
          include Metasploit::Cache::Spec::Matcher
          include_context 'Metasploit::Cache::Batch.batch'

          it 'should not add error on local' do
            new_email_address.valid?

            expect(new_email_address.errors[:full]).not_to include(error)
          end

          it 'should raise ActiveRecord::RecordNotUnique when saved' do
            expect {
              new_email_address.save
            }.to raise_record_not_unique
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
          include Metasploit::Cache::Spec::Matcher
          include_context 'Metasploit::Cache::Batch.batch'

          it 'should not add error on local' do
            new_email_address.valid?

            expect(new_email_address.errors[:local]).not_to include(error)
          end

          it 'should raise ActiveRecord::RecordNotUnique when saved' do
            expect {
              new_email_address.save
            }.to raise_record_not_unique
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

    it { should validate_presence_of :local }
  end

  context '#derived_domain' do
    subject(:derived_domain) do
      email_address.derived_domain
    end

    before(:each) do
      email_address.full = full
    end

    context 'with #full' do
      let(:domain) do
        FactoryGirl.generate :metasploit_cache_email_address_domain
      end

      let(:local) do
        FactoryGirl.generate :metasploit_cache_email_address_local
      end

      context "with '@'" do
        let(:full) do
          "#{local}@#{domain}"
        end


        context 'with local before @' do
          it "should be portion after '@'" do
            expect(derived_domain).to eq(domain)
          end
        end

        context 'without local before @' do
          let(:local) do
            ''
          end

          it "should be portion after '@'" do
            expect(derived_domain).to eq(domain)
          end
        end
      end

      context "without '@'" do
        let(:full) do
          local
        end

        it { should be_nil }
      end
    end

    context 'without #full' do
      let(:full) do
        ''
      end

      it { should be_nil }
    end
  end

  context '#derived_full' do
    subject(:derived_full) do
      email_address.derived_full
    end

    before(:each) do
      email_address.domain = domain
      email_address.local = local
    end

    context 'with domain' do
      let(:domain) do
        FactoryGirl.generate :metasploit_cache_email_address_domain
      end

      context 'with #local' do
        let(:local) do
          FactoryGirl.generate :metasploit_cache_email_address_local
        end

        it 'should <local>@<domain>' do
          expect(derived_full).to eq("#{local}@#{domain}")
        end
      end

      context 'without #local' do
        let(:local) do
          ''
        end

        it { should be_nil }
      end
    end

    context 'without #domain' do
      let(:domain) do
        ''
      end

      context 'with #local' do
        let(:local) do
          FactoryGirl.generate :metasploit_cache_email_address_local
        end

        it { should be_nil }
      end

      context 'without #local' do
        let(:local) do
          ''
        end

        it { should be_nil }
      end
    end
  end

  context '#derived_local' do
    subject(:derived_local) do
      email_address.derived_local
    end

    before(:each) do
      email_address.full = full
    end

    context 'with #full' do
      let(:domain) do
        FactoryGirl.generate :metasploit_cache_email_address_domain
      end

      let(:local) do
        FactoryGirl.generate :metasploit_cache_email_address_local
      end

      context "with '@'" do
        let(:full) do
          "#{local}@#{domain}"
        end


        context "with domain after '@'" do
          it "should be portion before '@'" do
            expect(derived_local).to eq(local)
          end
        end

        context "without domain after '@'" do
          let(:local) do
            ''
          end

          it "should be portion before '@'" do
            expect(derived_local).to eq(local)
          end
        end
      end

      context "without '@'" do
        let(:full) do
          local
        end

        it 'should be entirety of #full' do
          expect(derived_local).to eq(full)
        end
      end
    end

    context 'without #full' do
      let(:full) do
        ''
      end

      it { should be_nil }
    end
  end
end