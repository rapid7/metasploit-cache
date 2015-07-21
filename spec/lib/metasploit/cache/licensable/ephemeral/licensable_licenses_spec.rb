RSpec.describe Metasploit::Cache::Licensable::Ephemeral::LicensableLicenses do
  context 'build_added' do
    subject(:build_added) {
      described_class.build_added(
          destination: destination,
          destination_attribute_set: destination_attribute_set,
          source_attribute_set: source_attribute_set
      )
    }

    let(:destination) {
      Metasploit::Cache::Auxiliary::Instance.new
    }

    let(:destination_attribute_set) {
      Set.new
    }

    context 'with added' do
      context 'with existing Metasploit::Cache::License#abbreviation' do
        #
        # lets
        #

        let(:source_attribute_set) {
          Set.new [license.abbreviation]
        }

        #
        # let!s
        #

        let!(:license) {
          FactoryGirl.create(:metasploit_cache_license)
        }

        it 'builds destination.licensable_license' do
          expect {
            build_added
          }.to change(destination.licensable_licenses, :length).by(1)
        end

        it 'uses pre-existing Metasploit::Cache::License for destination.licensable_license Metasploit:::Cache::Licensable::Licensable#license' do
          build_added

          expect(destination.licensable_licenses.first.license).to eq(license)
        end

        it 'returns destination' do
          expect(build_added).to eq(destination)
        end
      end

      context 'with new Metasploit::Cache::License#abbrevation' do
        let(:license_abbreviation) {
          FactoryGirl.generate :metasploit_cache_license_abbreviation
        }

        let(:source_attribute_set) {
          Set.new [license_abbreviation]
        }

        it 'builds destination.licensable_license' do
          expect {
            build_added
          }.to change(destination.licensable_licenses, :length).by(1)
        end

        it 'builds new Metasploit::Cache::License' do
          build_added

          expect(destination.licensable_licenses.first.license).to be_new_record
        end

        it 'returns destination' do
          expect(build_added).to eq(destination)
        end
      end
    end

    context 'without added' do
      let(:source_attribute_set) {
        Set.new
      }

      it 'does not build any destination.licensable_licenses' do
        expect {
          build_added
        }.not_to change(destination.licensable_licenses, :length)
      end

      it 'returns destination' do
        expect(build_added).to eq(destination)
      end
    end
  end

  context 'destination_attribute_set' do
    subject(:destination_attribute_set) {
      described_class.destination_attribute_set(destination)
    }

    context 'with new record' do
      let(:destination) {
        Metasploit::Cache::Auxiliary::Instance.new
      }

      it { is_expected.to eq Set.new }
    end

    context 'with persisted record' do
      let!(:destination) {
        FactoryGirl.create(:metasploit_cache_auxiliary_instance)
      }

      it 'is destination.license Metasploit::Cache::License#abbreviations' do
        expect(destination_attribute_set).to eq Set.new(destination.licensable_licenses.map(&:license).map(&:abbreviation))
      end
    end
  end

  context 'destroy_removed' do
    subject(:destroy_removed) {
      described_class.destroy_removed(
                         destination: destination,
                         destination_attribute_set: destination_attribute_set,
                         source_attribute_set: source_attribute_set
      )
    }

    context 'with new record' do
      let(:destination) {
        Metasploit::Cache::Auxiliary::Instance.new
      }

      let(:destination_attribute_set) {
        Set.new
      }

      let(:source_attribute_set) {
        Set.new
      }

      it 'does not change destination.licenses' do
        expect {
          destroy_removed
        }.not_to change(destination.licenses, :count)
      end

      it 'returns destination' do
        expect(destroy_removed).to eq(destination)
      end
    end

    context 'with persisted record' do
      let!(:destination) {
        FactoryGirl.create(
            :metasploit_cache_auxiliary_instance,
            licensable_license_count: 2
        )
      }

      let(:destination_attribute_set) {
        Set.new destination.licenses.map(&:abbreviation)
      }

      context 'with removed' do
        let(:source_attribute_set) {
          Set.new [destination.licenses.first.abbreviation]
        }

        it 'destroys removed destination.licensable_licenses' do
          expect {
            destroy_removed
          }.to change(destination.licensable_licenses, :count).by(-1)
        end

        it 'returns destination' do
          expect(destroy_removed).to eq(destination)
        end
      end

      context 'without removed' do
        let(:source_attribute_set) {
          destination_attribute_set
        }

        it 'destroyes no destination.licensable_licenses' do
          expect {
            destroy_removed
          }.not_to change(destination.licensable_licenses, :count)
        end

        it 'returns destination' do
          expect(destroy_removed).to eq(destination)
        end
      end
    end
  end

  context 'source_attribute_set' do
    subject(:source_attribute_set) {
      described_class.source_attribute_set(source)
    }

    let(:source) {
      double('Metasploit Module instance', license: license)
    }

    context 'source.license' do
      context 'with nil' do
        let(:license) {
          nil
        }

        it { is_expected.to eq Set.new }
      end

      context 'with String' do
        let(:license) {
          FactoryGirl.generate :metasploit_cache_license_abbreviation
        }

        it 'is Set<String>' do
          expect(source_attribute_set).to eq(Set.new([license]))
        end
      end

      context 'with Array<String>' do
        let(:license) {
          Array.new(2) {
            FactoryGirl.generate :metasploit_cache_license_abbreviation
          }
        }

        it 'is Set<String>' do
          expect(source_attribute_set).to eq(Set.new(license))
        end
      end
    end
  end

  context 'synchronize' do
    subject(:synchronize) {
      described_class.synchronize(
          destination: destination,
          source: source
      )
    }

    let(:destination) {
      Metasploit::Cache::Auxiliary::Instance.new
    }

    let(:source) {
      double('Metasploit Module instance', license: nil)
    }

    it 'calls build_added' do
      expect(described_class).to receive(:build_added).with(
                                     hash_including(destination: destination)
                                 )

      synchronize
    end

    it 'calls destroy_removed' do
      expect(described_class).to receive(:destroy_removed).with(
                                     hash_including(destination: destination)
                                 )

      synchronize
    end
  end
end