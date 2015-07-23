RSpec.describe Metasploit::Cache::Architecturable::Ephemeral::ArchitecturableArchitectures do
  context 'build_added' do
    subject(:build_added) {
      described_class.build_added(
          destination: destination,
          destination_attribute_set: destination_attribute_set,
          source_attribute_set: source_attribute_set
      )
    }

    #
    # lets
    #

    let(:destination) {
      Metasploit::Cache::Encoder::Instance.new
    }

    let(:destination_attribute_set) {
      Set.new
    }

    context 'with added architecture abbreviations' do
      let(:source_architecture_abbreviation) {
        FactoryGirl.generate :metasploit_cache_architecture_abbreviation
      }

      let(:source_attribute_set) {
        Set.new [source_architecture_abbreviation]
      }

      it 'builds architecturable_architecture' do
        expect {
          build_added
        }.to change(destination.architecturable_architectures, :length).by(1)
      end

      it 'sets Metasploit::Cache::Architecturable::Architecture#architecture to Metaploit::Cache::Architecture with abbrevation' do
        expect(build_added.architecturable_architectures.first.architecture.abbreviation).to eq(source_architecture_abbreviation)
      end
    end

    context 'without added architecturablearchitectures' do
      let(:source_attribute_set) {
        Set.new
      }

      it 'does not build architecturablearchitecture' do
        expect {
          build_added
        }.not_to change(destination.architecturable_architectures, :length)
      end
    end
  end

  context 'destination_attribute_set' do
    subject(:destination_attribute_set) {
      described_class.destination_attribute_set(destination)
    }

    context 'with new record' do
      let(:destination) {
        Metasploit::Cache::Encoder::Instance.new
      }

      it { is_expected.to eq(Set.new) }
    end

    context 'with persisted record' do
      let(:architecture) {
        FactoryGirl.generate :metasploit_cache_architecture
      }

      let(:destination) {
        FactoryGirl.build(
            :metasploit_cache_encoder_instance,
            architecturable_architecture_count: 0
        ).tap { |architecturable|
          architecturable.architecturable_architectures.build(
              architecture: architecture
          )

          architecturable.save!
        }
      }

      it 'includes Metasploit::Cache::Architecture#abbreviation' do
        expect(destination_attribute_set).to include(architecture.abbreviation)
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
        Metasploit::Cache::Encoder::Instance.new
      }

      let(:destination_attribute_set) {
        Set.new
      }

      let(:source_attribute_set) {
        Set.new
      }

      it 'does not change destination.architecturable_architectures' do
        expect {
          mark_removed_for_destruction
        }.not_to change {
                   destination.architecturable_architectures(true).count
                 }
      end
    end

    context 'with persisted record' do
      #
      # lets
      #

      let(:destination_attribute_array) {
        [
            first_architecture.abbreviation,
            second_architecture.abbreviation
        ]
      }

      let(:destination_attribute_set) {
        Set.new destination_attribute_array
      }

      let(:first_architecture) {
        FactoryGirl.generate :metasploit_cache_architecture
      }

      let(:second_architecture) {
        FactoryGirl.generate :metasploit_cache_architecture
      }

      #
      # let!s
      #

      let!(:destination) {
        FactoryGirl.build(
                       :metasploit_cache_encoder_instance,
                       architecturable_architecture_count: 0
        ).tap { |architecturable|
          architecturable.architecturable_architectures.build(
              architecture: first_architecture
          )
          architecturable.architecturable_architectures.build(
              architecture: second_architecture
          )

          architecturable.save!
        }
      }

      context 'with empty removed attribute set' do
        let(:source_attribute_set) {
          destination_attribute_set
        }

        it 'does not change destination.architecturable_architectures' do
          expect {
            mark_removed_for_destruction
          }.not_to change {
                     destination.architecturable_architectures(true).count
                   }
        end
      end

      context 'with present removed attributes set' do
        context 'with matching architecture.abbreviation' do
          let(:source_attribute_set) {
            Set.new [
                        second_architecture.abbreviation
                    ]
          }

          it 'marks architecturable_architecture with architecture.abbreviation for destruction' do
            expect {
              mark_removed_for_destruction
            }.to change {
                   destination.architecturable_architectures.to_a.count(&:marked_for_destruction?)
                 }.by(1)
          end

          it 'does not remove architecturable_architecture with architecture.abbreviation' do
            expect {
              mark_removed_for_destruction
            }.not_to change(destination.architecturable_architectures, :count)
          end

          context 'with destination saved' do
            it 'removes architecturable_architecture with architecture.abbreviation' do
              mark_removed_for_destruction

              expect {
                destination.save!
              }.to change(destination.architecturable_architectures, :count).by(-1)

              expect(destination.architecturable_architectures(true).map(&:architecture)).to include(second_architecture)
            end
          end
        end

        context 'with multiple matches' do
          subject(:source_attribute_set) {
            Set.new
          }

          it 'marks all matching architecturable_architectures for destruction' do
            expect {
              mark_removed_for_destruction
            }.to change {
                   destination.architecturable_architectures.to_a.count(&:marked_for_destruction?)
                 }.by(2)
          end

          it 'does not remove architecturable_architectures' do
            expect {
              mark_removed_for_destruction
            }.not_to change(destination.architecturable_architectures, :count)
          end

          context 'with destination saved' do
            it 'removes all matching architecturable_architectures' do
              mark_removed_for_destruction
              expect {
                destination.save!
              }.to change(destination.architecturable_architectures, :count).by(-2)
            end
          end
        end
      end
    end
  end

  context 'reduce' do
    subject(:reduce) {
      described_class.reduce(
          destination: destination,
          destination_attribute_set: destination_attribute_set,
          source_attribute_set: source_attribute_set
      )
    }

    let(:destination) {
      Metasploit::Cache::Encoder::Instance.new
    }

    let(:destination_attribute_set) {
      Set.new
    }

    let(:source_attribute_set) {
      Set.new [FactoryGirl.generate(:metasploit_cache_architecture_abbreviation)]
    }

    let(:source) {
      double('Metasploit Module instance', arch: [])
    }

    it 'calls build_added' do
      expect(described_class).to receive(:build_added).with(
                                     hash_including(
                                         destination: destination,
                                         destination_attribute_set: destination_attribute_set,
                                         source_attribute_set: source_attribute_set
                                     )
                                 ).and_call_original

      reduce
    end

    it 'calls mark_removed_for_destruction' do
      expect(described_class).to receive(:mark_removed_for_destruction).with(
                                     hash_including(
                                         destination: destination,
                                         destination_attribute_set: destination_attribute_set,
                                         source_attribute_set: source_attribute_set                                     )
                                 ).and_call_original

      reduce
    end
  end

  context 'source_attribute_set' do
    subject(:source_attribute_set) {
      described_class.source_attribute_set(source)
    }

    let(:source) {
      double('Metasploit Module instance').tap { |architecturable|
        expect(architecturable).to receive(:arch).and_return(arch)
      }
    }

    context 'with empty arch' do
      let(:arch) {
        []
      }

      it { is_expected.to eq(Set.new) }
    end

    context 'with present arch' do
      let(:arch) {
        [
            architecture_abbreviation
        ]
      }

      let(:architecture_abbreviation) {
        FactoryGirl.generate :metasploit_cache_architecture_abbreviation
      }

      it 'includes elements of arch' do
        expect(source_attribute_set).to include(architecture_abbreviation)
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
      Metasploit::Cache::Encoder::Instance.new
    }

    let(:source) {
      double('Metasploit Module instance', arch: [])
    }

    it 'calls reduce' do
      expect(described_class).to receive(:reduce).with(
                                     hash_including(destination: destination)
                                 )

      synchronize
    end
  end
end