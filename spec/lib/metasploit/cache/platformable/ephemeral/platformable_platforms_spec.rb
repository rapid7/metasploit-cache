RSpec.describe Metasploit::Cache::Platformable::Ephemeral::PlatformablePlatforms do
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

    context 'with added platform fully_qualified_names' do
      let(:source_platform_fully_qualified_name) {
        FactoryGirl.generate :metasploit_cache_platform_fully_qualified_name
      }

      let(:source_attribute_set) {
        Set.new [source_platform_fully_qualified_name]
      }

      it 'builds platformable_platform' do
        expect {
          build_added
        }.to change(destination.platformable_platforms, :length).by(1)
      end

      it 'sets Metasploit::Cache::Platformable::Platform#platform to Metaploit::Cache::Platform with abbrevation' do
        expect(build_added.platformable_platforms.first.platform.fully_qualified_name).to eq(source_platform_fully_qualified_name)
      end
    end

    context 'without added platformableplatforms' do
      let(:source_attribute_set) {
        Set.new
      }

      it 'does not build platformableplatform' do
        expect {
          build_added
        }.not_to change(destination.platformable_platforms, :length)
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
      let(:platform) {
        FactoryGirl.generate :metasploit_cache_platform
      }

      let(:destination) {
        FactoryGirl.build(
            :metasploit_cache_encoder_instance,
            platformable_platform_count: 0
        ).tap { |platformable|
          platformable.platformable_platforms.build(
              platform: platform
          )

          platformable.save!
        }
      }

      it 'includes Metasploit::Cache::Platform#fully_qualified_name' do
        expect(destination_attribute_set).to include(platform.fully_qualified_name)
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
        Metasploit::Cache::Encoder::Instance.new
      }

      let(:destination_attribute_set) {
        Set.new
      }

      let(:source_attribute_set) {
        Set.new
      }

      it 'does not change destination.platformable_platforms' do
        expect {
          destroy_removed
        }.not_to change {
                   destination.platformable_platforms(true).count
                 }
      end
    end

    context 'with persisted record' do
      #
      # lets
      #

      let(:destination_attribute_array) {
        [
            first_platform.fully_qualified_name,
            second_platform.fully_qualified_name
        ]
      }

      let(:destination_attribute_set) {
        Set.new destination_attribute_array
      }

      let(:first_platform) {
        FactoryGirl.generate :metasploit_cache_platform
      }

      let(:second_platform) {
        FactoryGirl.generate :metasploit_cache_platform
      }

      #
      # let!s
      #

      let!(:destination) {
        FactoryGirl.build(
                       :metasploit_cache_encoder_instance,
                       platformable_platform_count: 0
        ).tap { |platformable|
          platformable.platformable_platforms.build(
              platform: first_platform
          )
          platformable.platformable_platforms.build(
              platform: second_platform
          )

          platformable.save!
        }
      }

      context 'with empty removed attribute set' do
        let(:source_attribute_set) {
          destination_attribute_set
        }

        it 'does not change destination.platformable_platforms' do
          expect {
            destroy_removed
          }.not_to change {
                     destination.platformable_platforms(true).count
                   }
        end
      end

      context 'with present removed attributes set' do
        context 'with matching platform.fully_qualified_name' do
          let(:source_attribute_set) {
            Set.new [
                        second_platform.fully_qualified_name
                    ]
          }

          it 'removes platformable_platform with platform.fully_qualified_name' do
            expect {
              destroy_removed
            }.to change(destination.platformable_platforms, :count).by(-1)

            expect(destination.platformable_platforms(true).map(&:platform)).to include(second_platform)
          end
        end

        context 'with multiple matches' do
          subject(:source_attribute_set) {
            Set.new
          }

          it 'removes all matching platformable_platforms' do
            expect {
              destroy_removed
            }.to change(destination.platformable_platforms, :count).by(-2)
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
      double('Metasploit Module instance').tap { |platformable|
        expect(platformable).to receive(:platform).and_return(
                                                      double(
                                                          'Platform List',
                                                          platforms: platforms
                                                      )
                                )
      }
    }

    context 'with empty platform.platforms' do
      let(:platforms) {
        []
      }

      it { is_expected.to eq(Set.new) }
    end

    context 'with present platform.platforms' do
      let(:platforms) {
        [
            double('Platform', realname: platform_fully_qualified_name)
        ]
      }

      let(:platform_fully_qualified_name) {
        FactoryGirl.generate :metasploit_cache_platform_fully_qualified_name
      }

      it 'includes platform.platforms #realname' do
        expect(source_attribute_set).to include(platform_fully_qualified_name)
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
      double(
          'Metasploit Module instance',
          platform: double(
              'Platform List',
              platforms: []
          )
      )
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