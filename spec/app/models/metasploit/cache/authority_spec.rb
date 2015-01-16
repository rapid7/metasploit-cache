RSpec.describe Metasploit::Cache::Authority do
  context 'associations' do
    it { should have_many(:module_instances).class_name('Metasploit::Cache::Module::Instance').through(:module_references) }
    it { should have_many(:module_references).class_name('Metasploit::Cache::Module::Reference').through(:references) }
    it { should have_many(:references).class_name('Metasploit::Cache::Reference').dependent(:destroy) }
  end

  context 'databases' do
    context 'columns' do
      it { should have_db_column(:abbreviation).of_type(:string).with_options(:null => false) }
      it { should have_db_column(:obsolete).of_type(:boolean).with_options(:default => false, :null => false)}
      it { should have_db_column(:summary).of_type(:string).with_options(:null => true) }
      it { should have_db_column(:url).of_type(:text).with_options(:null => true) }
    end

    context 'indices' do
      it { should have_db_index(:abbreviation).unique(true) }
      it { should have_db_index(:summary).unique(true) }
      it { should have_db_index(:url).unique(true) }
    end
  end

  context 'factories' do
    context :metasploit_cache_authority do
      subject(:metasploit_cache_authority) do
        FactoryGirl.build(:metasploit_cache_authority)
      end

      it { should be_valid }
    end

    context :full_metasploit_cache_authority do
      subject(:full_metasploit_cache_authority) do
        FactoryGirl.build(:full_metasploit_cache_authority)
      end

      it { should be_valid }

      it 'has a summary' do
        expect(full_metasploit_cache_authority.summary).not_to be_nil
      end

      it 'has a url' do
        expect(full_metasploit_cache_authority.url).not_to be_nil
      end
    end

    context :obsolete_metasploit_cache_authority do
      subject(:obsolete_metasploit_cache_authority) do
        FactoryGirl.build(:obsolete_metasploit_cache_authority)
      end

      it { should be_valid }

      it 'is obsolete' do
        expect(obsolete_metasploit_cache_authority.obsolete).to eq(true)
      end
    end
  end
  
  context 'sequences' do
    context 'seeded_metasploit_cache_authority' do
      subject(:seeded_metasploit_cache_authority) {
        FactoryGirl.generate :seeded_metasploit_cache_authority
      }
      
      context 'with seeded' do
        it 'does not create a new Metasploit::Cache::Authority' do
          expect {
            seeded_metasploit_cache_authority
          }.not_to change(Metasploit::Cache::Authority, :count)
        end

        it { is_expected.to be_a(Metasploit::Cache::Authority) }
        it { is_expected.to be_persisted }
      end

      context 'without seeded' do
        before(:each) do
          Metasploit::Cache::Authority.delete_all
        end

        it 'raises ArgumentError with the abbreviation of the unseeded authority' do
          expect {
            seeded_metasploit_cache_authority
          }.to raise_error(ArgumentError) do |error|
            expect(error.to_s).to match(/Metasploit::Cache::Authority with abbreviation \(\S+\) has not been seeded/)
          end
        end
      end
    end
  end

  context 'mass assignment security' do
    it { should allow_mass_assignment_of(:abbreviation) }
    it { should allow_mass_assignment_of(:obsolete) }
    it { should allow_mass_assignment_of(:summary) }
    it { should allow_mass_assignment_of(:url) }
  end

  context 'search' do
    let(:base_class) {
      Metasploit::Cache::Authority
    }

    context 'attributes' do
      it_should_behave_like 'search_attribute', :abbreviation, :type => :string
    end
  end

  context 'seeds' do
    it_should_behave_like 'Metasploit::Cache::Authority seed',
                          :abbreviation => 'BID',
                          :extension_name => 'Metasploit::Cache::Authority::Bid',
                          :obsolete => false,
                          :summary => 'BuqTraq ID',
                          :url => 'http://www.securityfocus.com/bid'

    it_should_behave_like 'Metasploit::Cache::Authority seed',
                          :abbreviation => 'CVE',
                          :extension_name => 'Metasploit::Cache::Authority::Cve',
                          :obsolete => false,
                          :summary => 'Common Vulnerabilities and Exposures',
                          :url => 'http://cvedetails.com'

    it_should_behave_like 'Metasploit::Cache::Authority seed',
                          :abbreviation => 'MIL',
                          :extension_name => nil,
                          :obsolete => true,
                          :summary => 'milw0rm',
                          :url => 'https://en.wikipedia.org/wiki/Milw0rm'

    it_should_behave_like 'Metasploit::Cache::Authority seed',
                          :abbreviation => 'MSB',
                          :extension_name => 'Metasploit::Cache::Authority::Msb',
                          :obsolete => false,
                          :summary => 'Microsoft Security Bulletin',
                          :url => 'http://www.microsoft.com/technet/security/bulletin'

    it_should_behave_like 'Metasploit::Cache::Authority seed',
                          :abbreviation => 'OSVDB',
                          :extension_name => 'Metasploit::Cache::Authority::Osvdb',
                          :obsolete => false,
                          :summary => 'Open Sourced Vulnerability Database',
                          :url => 'http://osvdb.org'

    it_should_behave_like 'Metasploit::Cache::Authority seed',
                          :abbreviation => 'PMASA',
                          :extension_name => 'Metasploit::Cache::Authority::Pmasa',
                          :obsolete => false,
                          :summary => 'phpMyAdmin Security Announcement',
                          :url => 'http://www.phpmyadmin.net/home_page/security/'

    it_should_behave_like 'Metasploit::Cache::Authority seed',
                          :abbreviation => 'SECUNIA',
                          :extension_name => 'Metasploit::Cache::Authority::Secunia',
                          :obsolete => false,
                          :summary => 'Secunia',
                          :url => 'https://secunia.com/advisories'

    it_should_behave_like 'Metasploit::Cache::Authority seed',
                          :abbreviation => 'US-CERT-VU',
                          :extension_name => 'Metasploit::Cache::Authority::UsCertVu',
                          :obsolete => false,
                          :summary => 'United States Computer Emergency Readiness Team Vulnerability Notes Database',
                          :url => 'http://www.kb.cert.org/vuls'

    it_should_behave_like 'Metasploit::Cache::Authority seed',
                          :abbreviation => 'waraxe',
                          :extension_name => 'Metasploit::Cache::Authority::Waraxe',
                          :obsolete => false,
                          :summary => 'Waraxe Advisories',
                          :url => 'http://www.waraxe.us/content-cat-1.html'

    it_should_behave_like 'Metasploit::Cache::Authority seed',
                          abbreviation: 'ZDI',
                          extension_name: 'Metasploit::Cache::Authority::Zdi',
                          obsolete: false,
                          summary: 'Zero Day Initiative',
                          url: 'http://www.zerodayinitiative.com/advisories'
  end

  context 'validations' do
    #
    # lets
    #

    let(:error) do
      I18n.translate!('metasploit.model.errors.messages.taken')
    end

    #
    # let!s
    #

    let!(:existing_authority) do
      FactoryGirl.create(:full_metasploit_cache_authority)
    end

    it { should validate_presence_of(:abbreviation) }

    context 'validates uniqueness of abbreviation' do
      context 'with same #abbreviation' do
        let(:new_authority) do
          FactoryGirl.build(
              :metasploit_cache_authority,
              abbreviation: existing_authority.abbreviation
          )
        end

        context 'with batched' do
          include_context 'Metasploit::Cache::Batch.batch'

          it 'should not add error on #abbreviation' do
            new_authority.valid?

            expect(new_authority.errors[:abbreviation]).not_to include(error)
          end

          it 'should raise ActiveRecord::RecordNotUnique when saved' do
            expect {
              new_authority.save
            }.to raise_error(ActiveRecord::RecordNotUnique)
          end
        end

        context 'without batched' do
          it 'should add error on #abbreviation' do
            new_authority.valid?

            expect(new_authority.errors[:abbreviation]).to include(error)
          end
        end
      end
    end

    context 'validates uniqueness of summary' do
      context 'with same #summary' do
        let(:new_authority) do
          FactoryGirl.build(
              :metasploit_cache_authority,
              summary: existing_authority.summary
          )
        end

        context 'with batched' do
          include_context 'Metasploit::Cache::Batch.batch'

          it 'should not add error on #summary' do
            new_authority.valid?

            expect(new_authority.errors[:summary]).not_to include(error)
          end

          it 'should raise ActiveRecord::RecordNotUnique when saved' do
            expect {
              new_authority.save
            }.to raise_error(ActiveRecord::RecordNotUnique)
          end
        end

        context 'without batched' do
          it 'should add error on #summary' do
            new_authority.valid?

            expect(new_authority.errors[:summary]).to include(error)
          end
        end
      end
    end

    context 'validates uniqueness of url' do
      context 'with same #url' do
        let(:new_authority) do
          FactoryGirl.build(
              :metasploit_cache_authority,
              url: existing_authority.url
          )
        end

        context 'with batched' do
          include_context 'Metasploit::Cache::Batch.batch'

          it 'should not add error on #url' do
            new_authority.valid?

            expect(new_authority.errors[:url]).not_to include(error)
          end

          it 'should raise ActiveRecord::RecordNotUnique when saved' do
            expect {
              new_authority.save
            }.to raise_error(ActiveRecord::RecordNotUnique)
          end
        end

        context 'without batched' do
          it 'should add error on #url' do
            new_authority.valid?

            expect(new_authority.errors[:url]).to include(error)
          end
        end
      end
    end
  end
end