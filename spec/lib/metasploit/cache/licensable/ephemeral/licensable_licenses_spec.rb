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

  context 'mark_removed_for_destruction' do
    subject(:mark_removed_for_destruction) {
      described_class.mark_removed_for_destruction(
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

      it 'does not mark for destruction any destination.licensable_licenses' do
        expect {
          mark_removed_for_destruction
        }.not_to change {
                   destination.licensable_licenses.each.count(&:marked_for_destruction?)
                 }
      end

      it 'does not destroy any destination.licensable_licenses' do
        expect {
          mark_removed_for_destruction
        }.not_to change(destination.licensable_licenses, :count)
      end

      it 'returns destination' do
        expect(mark_removed_for_destruction).to eq(destination)
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

        it 'does not destroy any destination.licensable_licenses' do
          expect {
            mark_removed_for_destruction
          }.not_to change(destination.licensable_licenses, :count)
        end

        it 'marks for destruction removed destination.licensable_licenses' do
          expect {
            mark_removed_for_destruction
          }.to change {
                 destination.licensable_licenses.each.count(&:marked_for_destruction?)
               }
        end

        it 'returns destination' do
          expect(mark_removed_for_destruction).to eq(destination)
        end

        context 'with saved destination' do
          it 'destroys removed destination.licensable_licenses' do
            mark_removed_for_destruction

            expect {
              destination.save!
            }.to change(destination.licensable_licenses, :count).by(-1)
          end
        end
      end

      context 'without removed' do
        let(:source_attribute_set) {
          destination_attribute_set
        }

        it 'destroys no destination.licensable_licenses' do
          expect {
            mark_removed_for_destruction
          }.not_to change(destination.licensable_licenses, :count)
        end

        it 'marks for destruction no destination.licensable_licenses' do
          expect {
            mark_removed_for_destruction
          }.not_to change(destination.licensable_licenses, :count)
        end

        it 'returns destination' do
          expect(mark_removed_for_destruction).to eq(destination)
        end

        context 'with destination saved' do
          it 'destroys no destination.licensable_licenses' do
            expect {
              mark_removed_for_destruction
            }.not_to change(destination.licensable_licenses, :count)
          end
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

    it 'calls mark_removed_for_destruction' do
      expect(described_class).to receive(:mark_removed_for_destruction).with(
                                     hash_including(destination: destination)
                                 )

      synchronize
    end
  end
end