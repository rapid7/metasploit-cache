RSpec.describe Metasploit::Cache::Reference do
  context 'associations' do
    it { is_expected.to have_many(:auxiliary_instances).class_name('Metasploit::Cache::Auxiliary::Instance').source(:referencable).through(:referencable_references) }
    it { is_expected.to belong_to(:authority).class_name('Metasploit::Cache::Authority').inverse_of(:references) }
    it { is_expected.to have_many(:exploit_instances).class_name('Metasploit::Cache::Exploit::Instance').source(:referencable).through(:referencable_references) }
    it { is_expected.to have_many(:module_instances).class_name('Metasploit::Cache::Module::Instance').through(:module_references) }
    it { is_expected.to have_many(:module_references).class_name('Metasploit::Cache::Module::Reference').dependent(:destroy).inverse_of(:references).with_foreign_key(:reference_id) }
    it { is_expected.to have_many(:post_instances).class_name('Metasploit::Cache::Post::Instance').source(:referencable).through(:referencable_references) }
    it { is_expected.to have_many(:referencable_references).class_name('Metasploit::Cache::Referencable::Reference').dependent(:destroy).inverse_of(:references).with_foreign_key(:reference_id) }
  end

  context 'derivation' do
    subject(:reference) do
      FactoryGirl.build(
          :metasploit_cache_reference,
          :authority => authority,
          :designation => designation
      )
    end

    let(:base_class) {
      Metasploit::Cache::Reference
    }

    context 'with authority' do
      include_context 'ActiveRecord attribute_type'

      let(:authority) do
        Metasploit::Cache::Authority.where(abbreviation: abbreviation).first
      end

      context 'with abbreviation' do
        context 'BID' do
          let(:abbreviation) do
            'BID'
          end

          let(:designation) do
            FactoryGirl.generate :metasploit_cache_reference_bid_designation
          end

          it_should_behave_like 'derives', :url, :validates => false
        end

        context 'CVE' do
          let(:abbreviation) do
            'CVE'
          end

          let(:designation) do
            FactoryGirl.generate :metasploit_cache_reference_cve_designation
          end

          it_should_behave_like 'derives', :url, :validates => false
        end

        context 'CWE' do
          let(:abbreviation) {
            'CWE'
          }

          let(:designation) {
            FactoryGirl.generate :metasploit_cache_reference_cwe_designation
          }

          it_should_behave_like 'derives',
                                :url,
                                validates: false
        end

        context 'EDB' do
          let(:abbreviation) {
            'EDB'
          }

          let(:designation) {
            FactoryGirl.generate :metasploit_cache_reference_edb_designation
          }

          it_should_behave_like 'derives',
                                :url,
                                validates: false
        end

        context 'MSB' do
          let(:abbreviation) do
            'MSB'
          end

          let(:designation) do
            FactoryGirl.generate :metasploit_cache_reference_msb_designation
          end

          it_should_behave_like 'derives', :url, :validates => false
        end

        context 'OSVDB' do
          let(:abbreviation) do
            'OSVDB'
          end

          let(:designation) do
            FactoryGirl.generate :metasploit_cache_reference_osvdb_designation
          end

          it_should_behave_like 'derives', :url, :validates => false
        end

        context 'PMASA' do
          let(:abbreviation) do
            'PMASA'
          end

          let(:designation) do
            FactoryGirl.generate :metasploit_cache_reference_pmasa_designation
          end

          it_should_behave_like 'derives', :url, :validates => false
        end

        context 'SECUNIA' do
          let(:abbreviation) do
            'SECUNIA'
          end

          let(:designation) do
            FactoryGirl.generate :metasploit_cache_reference_secunia_designation
          end

          it_should_behave_like 'derives', :url, :validates => false
        end

        context 'US-CERT-VU' do
          let(:abbreviation) do
            'US-CERT-VU'
          end

          let(:designation) do
            FactoryGirl.generate :metasploit_cache_reference_us_cert_vu_designation
          end

          it_should_behave_like 'derives', :url, :validates => false
        end

        context 'waraxe' do
          let(:abbreviation) do
            'waraxe'
          end

          let(:designation) do
            FactoryGirl.generate :metasploit_cache_reference_waraxe_designation
          end

          it_should_behave_like 'derives', :url, :validates => false
        end

        context 'WPVDB' do
          let(:abbreviation) do
            'WPVDB'
          end

          let(:designation) do
            FactoryGirl.generate :metasploit_cache_reference_wpvdb_designation
          end

          it_should_behave_like 'derives',
                                :url,
                                validates: false
        end

        context 'ZDI' do
          let(:abbreviation) do
            'ZDI'
          end

          let(:designation) do
            FactoryGirl.generate :metasploit_cache_reference_zdi_designation
          end

          it_should_behave_like 'derives', :url, validates: false
        end
      end
    end
  end

  context 'factories' do
    context :metasploit_cache_reference do
      subject(:metasploit_cache_reference) do
        FactoryGirl.build(:metasploit_cache_reference)
      end

      it { should be_valid }

      it 'has and authority' do
        expect(metasploit_cache_reference.authority).not_to be_nil
      end

      it 'has a designation' do
        expect(metasploit_cache_reference.designation).not_to be_nil
      end

      it 'has a url' do
        expect(metasploit_cache_reference.url).not_to be_nil
      end
    end

    context :obsolete_metasploit_cache_reference do
      subject(:obsolete_metasploit_cache_reference) do
        FactoryGirl.build(:obsolete_metasploit_cache_reference)
      end

      it { should be_valid }

      it 'has an authority' do
        expect(obsolete_metasploit_cache_reference.authority).not_to be_nil
      end

      it 'has a designation' do
        expect(obsolete_metasploit_cache_reference.designation).not_to be_nil
      end

      it 'does not have a url' do
        expect(obsolete_metasploit_cache_reference.url).to be_nil
      end
    end

    context :url_metasploit_cache_reference do
      subject(:url_metasploit_cache_reference) do
        FactoryGirl.build(:url_metasploit_cache_reference)
      end

      it { should be_valid }

      it 'does not have an authority' do
        expect(url_metasploit_cache_reference.authority).to be_nil
      end

      it 'does not have a designation' do
        expect(url_metasploit_cache_reference.designation).to be_nil
      end

      it 'has a url' do
        expect(url_metasploit_cache_reference.url).not_to be_nil
      end
    end
  end

  context 'search' do
    let(:base_class) {
      Metasploit::Cache::Reference
    }

    context 'attributes' do
      it_should_behave_like 'search_attribute', :designation, :type => :string
      it_should_behave_like 'search_attribute', :url, :type => :string
    end
  end

  context 'validations' do
    subject(:reference) do
      FactoryGirl.build(
          :metasploit_cache_reference,
          :authority => authority,
          :designation => designation,
          :url => url
      )
    end

    context 'with authority' do
      let(:authority) do
        FactoryGirl.create(:metasploit_cache_authority)
      end

      context 'with designation' do
        let(:designation) do
          FactoryGirl.generate :metasploit_cache_reference_designation
        end

        context 'with url' do
          let(:url) do
            FactoryGirl.generate :metasploit_cache_reference_url
          end

          it { should be_valid }
        end

        context 'without url' do
          let(:url) do
            nil
          end

          it { should be_valid }
        end
      end

      context 'without designation' do
        let(:designation) do
          nil
        end

        context 'with url' do
          let(:url) do
            FactoryGirl.generate :metasploit_cache_reference_url
          end

          it { should be_invalid }

          it 'should record error on designation' do
            reference.valid?

            expect(reference.errors[:designation]).to include("can't be blank")
          end

          it 'should not record error on url' do
            reference.valid?

            expect(reference.errors[:url]).to be_empty
          end
        end

        context 'without url' do
          let(:url) do
            nil
          end

          it { should be_invalid }

          it 'should record error on designation' do
            reference.valid?

            expect(reference.errors[:designation]).to include("can't be blank")
          end

          it 'should not record error on url' do
            reference.valid?

            expect(reference.errors[:url]).to be_empty
          end
        end
      end
    end

    context 'without authority' do
      let(:authority) do
        nil
      end

      context 'with designation' do
        let(:designation) do
          FactoryGirl.generate :metasploit_cache_reference_designation
        end

        let(:url) do
          nil
        end

        it { should be_invalid }

        it 'should record error on designation' do
          reference.valid?

          expect(reference.errors[:designation]).to include('must be nil')
        end
      end

      context 'without designation' do
        let(:designation) do
          nil
        end

        context 'with url' do
          let(:url) do
            FactoryGirl.generate :metasploit_cache_reference_url
          end

          it { should be_valid }
        end

        context 'without url' do
          let(:url) do
            nil
          end

          it { should be_invalid }

          it 'should record error on url' do
            reference.valid?

            expect(reference.errors[:url]).to include("can't be blank")
          end
        end
      end
    end
  end

  context '#derived_url' do
    subject(:derived_url) do
      reference.derived_url
    end

    let(:reference) do
      FactoryGirl.build(
          :metasploit_cache_reference,
          :authority => authority,
          :designation => designation
      )
    end

    context 'with authority' do
      let(:authority) do
        FactoryGirl.create(:metasploit_cache_authority)
      end

      context 'with blank designation' do
        let(:designation) do
          ''
        end

        it { should be_nil }
      end

      context 'without blank designation' do
        let(:designation) do
          '31337'
        end

        it 'should call Metasploit::Cache::Authority#designation_url' do
          expect(authority).to receive(:designation_url).with(designation)

          derived_url
        end
      end
    end

    context 'without authority' do
      let(:authority) do
        nil
      end

      let(:designation) do
        nil
      end

      it { should be_nil }
    end
  end

  context '#authority?' do
    subject(:authority?) do
      reference.authority?
    end

    let(:reference) do
      FactoryGirl.build(
          :metasploit_cache_reference,
          :authority => authority
      )
    end

    context 'with authority' do
      let(:authority) do
        FactoryGirl.create(:metasploit_cache_authority)
      end

      it { is_expected.to eq(true) }
    end

    context 'without authority' do
      let(:authority) do
        nil
      end

      it { is_expected.to eq(false) }
    end
  end
end