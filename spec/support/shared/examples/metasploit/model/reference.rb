Metasploit::Model::Spec.shared_examples_for 'Reference' do
  #
  # Authority factories
  #

  authority_factory = "#{factory_namespace}_authority"

  #
  # Reference factoriess
  #

  obsolete_reference_factory = "obsolete_#{reference_factory}"
  url_reference_factory = "url_#{reference_factory}"

  context 'derivation' do
    subject(:reference) do
      FactoryGirl.build(
          reference_factory,
          :authority => authority,
          :designation => designation
      )
    end

    context 'with authority' do
      let(:authority) do
        authority_with_abbreviation(abbreviation)
      end

      context 'with abbreviation' do
        context 'BID' do
          let(:abbreviation) do
            'BID'
          end

          let(:designation) do
            FactoryGirl.generate :metasploit_model_reference_bid_designation
          end

          it_should_behave_like 'derives', :url, :validates => false
        end

        context 'CVE' do
          let(:abbreviation) do
            'CVE'
          end

          let(:designation) do
            FactoryGirl.generate :metasploit_model_reference_cve_designation
          end

          it_should_behave_like 'derives', :url, :validates => false
        end

        context 'MSB' do
          let(:abbreviation) do
            'MSB'
          end

          let(:designation) do
            FactoryGirl.generate :metasploit_model_reference_msb_designation
          end

          it_should_behave_like 'derives', :url, :validates => false
        end

        context 'OSVDB' do
          let(:abbreviation) do
            'OSVDB'
          end

          let(:designation) do
            FactoryGirl.generate :metasploit_model_reference_osvdb_designation
          end

          it_should_behave_like 'derives', :url, :validates => false
        end

        context 'PMASA' do
          let(:abbreviation) do
            'PMASA'
          end

          let(:designation) do
            FactoryGirl.generate :metasploit_model_reference_pmasa_designation
          end

          it_should_behave_like 'derives', :url, :validates => false
        end

        context 'SECUNIA' do
          let(:abbreviation) do
            'SECUNIA'
          end

          let(:designation) do
            FactoryGirl.generate :metasploit_model_reference_secunia_designation
          end

          it_should_behave_like 'derives', :url, :validates => false
        end

        context 'US-CERT-VU' do
          let(:abbreviation) do
            'US-CERT-VU'
          end

          let(:designation) do
            FactoryGirl.generate :metasploit_model_reference_us_cert_vu_designation
          end

          it_should_behave_like 'derives', :url, :validates => false
        end

        context 'waraxe' do
          let(:abbreviation) do
            'waraxe'
          end

          let(:designation) do
            FactoryGirl.generate :metasploit_model_reference_waraxe_designation
          end

          it_should_behave_like 'derives', :url, :validates => false
        end

        context 'ZDI' do
          let(:abbreviation) do
            'ZDI'
          end

          let(:designation) do
            FactoryGirl.generate :metasploit_model_reference_zdi_designation
          end

          it_should_behave_like 'derives', :url, validates: false
        end
      end
    end
  end

  context 'factories' do
    context reference_factory do
      subject(reference_factory) do
        FactoryGirl.build(reference_factory)
      end

      it { should be_valid }

      it 'has and authority' do
        expect(send(reference_factory).authority).not_to be_nil
      end
      
      it 'has a designation' do
        expect(send(reference_factory).designation).not_to be_nil
      end
     
      it 'has a url' do
        expect(send(reference_factory).url).not_to be_nil
      end
    end

    context obsolete_reference_factory do
      subject(obsolete_reference_factory) do
        FactoryGirl.build(obsolete_reference_factory)
      end

      it { should be_valid }

      it 'has an authority' do
        expect(send(obsolete_reference_factory).authority).not_to be_nil
      end
      
      it 'has a designation' do
        expect(send(obsolete_reference_factory).designation).not_to be_nil
      end
     
      it 'does not have a url' do
        expect(send(obsolete_reference_factory).url).to be_nil
      end
    end

    context url_reference_factory do
      subject(url_reference_factory) do
        FactoryGirl.build(url_reference_factory)
      end

      it { should be_valid }

      it 'does not have an authority' do
        expect(send(url_reference_factory).authority).to be_nil
      end
      
      it 'does not have a designation' do
        expect(send(url_reference_factory).designation).to be_nil
      end
     
      it 'has a url' do
        expect(send(url_reference_factory).url).not_to be_nil
      end
    end
  end

  context 'mass assignment security' do
    it { should allow_mass_assignment_of(:designation) }
    it { should allow_mass_assignment_of(:url) }
  end

  context 'search' do
    context 'attributes' do
      it_should_behave_like 'search_attribute', :designation, :type => :string
      it_should_behave_like 'search_attribute', :url, :type => :string
    end
  end

  context 'validations' do
    subject(:reference) do
      FactoryGirl.build(
          reference_factory,
          :authority => authority,
          :designation => designation,
          :url => url
      )
    end

    context 'with authority' do
      let(:authority) do
        FactoryGirl.create(authority_factory)
      end

      context 'with designation' do
        let(:designation) do
          FactoryGirl.generate :metasploit_model_reference_designation
        end

        context 'with url' do
          let(:url) do
            FactoryGirl.generate :metasploit_model_reference_url
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
            FactoryGirl.generate :metasploit_model_reference_url
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
          FactoryGirl.generate :metasploit_model_reference_designation
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
            FactoryGirl.generate :metasploit_model_reference_url
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
          reference_factory,
          :authority => authority,
          :designation => designation
      )
    end

    context 'with authority' do
      let(:authority) do
        FactoryGirl.create(
            authority_factory
        )
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

        it 'should call Metasploit::Model::Authority#designation_url' do
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
          reference_factory,
          :authority => authority
      )
    end

    context 'with authority' do
      let(:authority) do
        FactoryGirl.create(authority_factory)
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