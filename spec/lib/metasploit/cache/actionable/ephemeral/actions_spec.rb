RSpec.describe Metasploit::Cache::Actionable::Ephemeral::Actions do
  context 'build_added' do
    subject(:build_added) {
      described_class.build_added(
          destination: destination,
          destination_attribute_set: destination_attribute_set,
          source_attribute_set: source_attribute_set
      )
    }

    context 'with empty :destination_attribute_set' do
      let(:destination) {
        Metasploit::Cache::Auxiliary::Instance.new
      }

      let(:destination_attribute_set) {
        Set.new []
      }

      context 'with empty :source_attribute_set' do
        let(:source_attribute_set) {
          Set.new []
        }

        it 'does not build any actions on destination' do
          expect {
            build_added
          }.not_to change {
                     destination.actions.length
                   }
        end
      end

      context 'with present :source_attribute_set' do
        let(:source_attribute_set) {
          Set.new [source_name]
        }

        let(:source_name) {
          FactoryGirl.generate :metasploit_cache_actionable_action_name
        }

        it 'builds actions with names in source_attribute_set' do
          expect {
            build_added
          }.to change {
                 destination.actions.length
               }.by(source_attribute_set.length)

          expect(destination.actions.first.name).to eq(source_name)
        end
      end
    end

    context 'with present :destination_attribute_set' do
      let(:destination) {
        Metasploit::Cache::Auxiliary::Instance.new.tap { |auxiliary_instance|
          auxiliary_instance.actions.build(name: destination_name)
        }
      }

      let(:destination_attribute_set) {
        Set.new [destination_name]
      }

      let(:destination_name) {
        FactoryGirl.generate :metasploit_cache_actionable_action_name
      }

      context 'with empty :source_attribute_set' do
        let(:source_attribute_set) {
          Set.new []
        }

        it 'does not build any actions on destination' do
          expect {
            build_added
          }.not_to change {
                     destination.actions.length
                   }
        end
      end

      context 'with equal :destination_attribute_set' do
        let(:source_attribute_set) {
          destination_attribute_set
        }

        it 'does not build any actions on destination' do
          expect {
            build_added
          }.not_to change {
                     destination.actions.length
                   }
        end
      end

      context 'with disjoint :destination_attribute_set' do
        let(:source_attribute_set) {
          Set.new [source_name]
        }

        let(:source_name) {
          FactoryGirl.generate :metasploit_cache_actionable_action_name
        }

        it 'builds actions with names in source_attribute_set' do
          expect {
            build_added
          }.to change {
                 destination.actions.length
               }.by(source_attribute_set.length)

          expect(destination.actions.map(&:name)).to include(source_name)
        end
      end

      context 'with superset of :destination_attribute_set' do
        let(:source_attribute_set) {
          Set.new [destination_name, source_only_name]
        }

        let(:source_only_name) {
          FactoryGirl.generate :metasploit_cache_actionable_action_name
        }

        it "builds actions in :source_attribute_set that aren't in :destination_attribute_set" do
          expect {
            build_added
          }.to change {
                 destination.actions.length
               }.by(1)

          expect(destination.actions.map(&:name)).to contain_exactly(destination_name, source_only_name)
        end
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

      it { is_expected.to be_a Set }
      it { is_expected.to be_empty }
    end

    context 'with persisted record' do
      let!(:destination) {
        FactoryGirl.create(:metasploit_cache_auxiliary_instance)
      }

      it { is_expected.to be_a Set }

      it "contains all action names" do
        expect(destination_attribute_set).to eq(Set.new [destination.actions.first.name])
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

    context 'with new :destination' do
      let(:destination) {
        Metasploit::Cache::Auxiliary::Instance.new
      }

      context 'with empty :destination_attribute_set' do
        let(:destination_attribute_set) {
          Set.new
        }

        context 'with empty :source_attribute_set' do
          let(:source_attribute_set) {
            Set.new
          }

          it 'does not mark any destination.actions for destruction' do
            expect {
              mark_removed_for_destruction
            }.not_to change {
                       destination.actions.each.count(&:marked_for_destruction?)
                     }
          end
        end

        context 'with present :source_attribute_set' do
          let(:source_attribute_set) {
            Set.new [source_name]
          }

          let(:source_name) {
            FactoryGirl.generate :metasploit_cache_actionable_action_name
          }

          it 'does not mark any destination.actions for destruction' do
            expect {
              mark_removed_for_destruction
            }.not_to change {
                       destination.actions.each.count(&:marked_for_destruction?)
                     }
          end
        end
      end
    end

    context 'with persisted destination' do
      context 'with empty :destination_attribute_set' do
        #
        # lets
        #

        let(:destination_attribute_set) {
          Set.new
        }

        #
        # let!s
        #

        let!(:destination) {
          FactoryGirl.create(:metasploit_cache_post_instance)
        }

        context 'with empty :source_attribute_set' do
          let(:source_attribute_set) {
            Set.new
          }

          it 'does not mark any destination.actions for destruction' do
            expect {
              mark_removed_for_destruction
            }.not_to change {
                       destination.actions.each.count(&:marked_for_destruction?)
                     }
          end
        end

        context 'with present :source_attribute_set' do
          let(:source_attribute_set) {
            Set.new [source_name]
          }

          let(:source_name) {
            FactoryGirl.generate :metasploit_cache_actionable_action_name
          }

          it "doesn't mark any destination.actions for destruction" do
            expect {
              mark_removed_for_destruction
            }.not_to change {
                       destination.actions.each.count(&:marked_for_destruction)
                     }
          end
        end
      end

      context 'with present :destination_attribute_set' do
        #
        # let!s
        #

        let!(:destination) {
          FactoryGirl.create(
              :metasploit_cache_auxiliary_instance,
              action_count: 2
          )
        }

        #
        # lets
        #

        let(:destination_attribute_set) {
          Set.new destination.actions.map(&:name)
        }

        context 'with equal :source_attribute_set' do
          let(:source_attribute_set) {
            destination_attribute_set
          }

          it "doesn't mark and actions for destruction" do
            expect {
              mark_removed_for_destruction
            }.not_to change {
                       destination.actions.each.count(&:marked_for_destruction?)
                     }
          end
        end

        context 'with disjoint :source_attribute_set' do
          let(:source_attribute_set) {
            Set.new [source_name]
          }

          let(:source_name) {
            FactoryGirl.generate :metasploit_cache_actionable_action_name
          }

          it 'marks all actions for destruction' do
            expect {
              mark_removed_for_destruction
            }.to change { destination.actions.each.count(&:marked_for_destruction?) }.to(2)
          end

          it 'does not destroy any actions' do
            expect {
              mark_removed_for_destruction
            }.not_to change(destination.actions, :count)
          end

          context 'with destination saved' do
            it 'destroys all actions' do
              mark_removed_for_destruction

              expect {
                destination.save!
              }.to change(destination.actions, :count).to(0)
            end
          end
        end

        context 'with subset :source_attribute_set' do
          let(:source_attribute_set) {
            Set.new [destination_attribute_set.first]
          }

          it 'marks actions with name in destination_attribute_set, but not source_attribute_set for destruction' do
            expect {
              mark_removed_for_destruction
            }.to change { destination.actions.each.count(&:marked_for_destruction?) }.by(1)
          end

          it 'does not destory any actions' do
            expect {
              mark_removed_for_destruction
            }.not_to change(destination.actions, :count)
          end

          context 'with destination saved' do
            it 'destroys actions with name in :destination_attribute_set, but not :source_attribute_set' do
              mark_removed_for_destruction

              expect {
                destination.save!
              }.to change(destination.actions, :count).by(-1)

              expect(destination.reload.actions.map(&:name)).to match_array(source_attribute_set)
            end
          end
        end

        context 'with superset :source_attribute_set' do
          let(:source_attribute_set) {
            Set.new([source_only_name]).union(destination_attribute_set)
          }

          let(:source_only_name) {
            FactoryGirl.generate :metasploit_cache_actionable_action_name
          }

          it "doesn't mark any actions for destruction" do
            expect {
              mark_removed_for_destruction
            }.not_to change {
                       destination.actions.each.count(&:marked_for_destruction?)
                     }
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
      double("Metasploit Module instance").tap { |metasploit_module_instance|
        allow(metasploit_module_instance).to receive(:actions).and_return(source_actions)
      }
    }

    context 'with empty source #actions' do
      let(:source_actions) {
        []
      }

      it 'is an empty Set' do
        expect(source_attribute_set).to eq(Set.new)
      end
    end

    context 'with present source #actions' do
      let(:source_actions) {
        source_action_names.map { |name|
          double('Metasploit Module action', name: name)
        }
      }

      let(:source_action_names) {
        [FactoryGirl.generate(:metasploit_cache_actionable_action_name)]
      }

      it 'is set of #name of #actions of source' do
        expect(source_attribute_set).to eq(Set.new source_action_names)
      end
    end
  end

  context 'source_default_action_name' do
    subject(:source_default_action_name) {
      described_class.source_default_action_name(source)
    }

    let(:source) {
      double('Metasploit Module instance')
    }

    let(:source_default_action) {
      FactoryGirl.generate :metasploit_cache_actionable_action_name
    }

    it 'calls #default_action on source' do
      expect(source).to receive(:default_action).and_return(source_default_action)

      expect(source_default_action_name).to eq(source_default_action)
    end
  end

  context 'synchronize' do
    subject(:synchronize) {
      described_class.synchronize(
          destination: destination,
          source: source
      )
    }

    #
    # lets
    #

    let(:source) {
      double(
          'Metasploit Module instance',
          actions: [],
          default_action: nil
      )
    }

    #
    # let!s
    #

    let!(:destination) {
      FactoryGirl.create(
          :metasploit_cache_auxiliary_instance,
          action_count: 2
      )
    }

    it 'calls mark_removed_for_destruction' do
      expect(described_class).to receive(:mark_removed_for_destruction).with(
                                     hash_including(destination: destination)
                                 ).and_call_original

      synchronize
    end

    it 'calls build_added' do
      expect(described_class).to receive(:build_added).with(
                                     hash_including(destination: destination)
                                 ).and_call_original

      synchronize
    end

    it 'calls update_default_action' do
      expect(described_class).to receive(:update_default_action).with(
                                     hash_including(destination: destination)
                                 ).and_call_original

      synchronize
    end

    it 'returns destination' do
      expect(synchronize).to eq(destination)
    end
  end

  context 'update_default_action' do
    subject(:update_default_action) {
      described_class.update_default_action(
        destination: destination,
        source: source
      )
    }

    #
    # lets
    #

    let(:destination) {
      FactoryGirl.build(
          :metasploit_cache_auxiliary_instance,
          action_count: 1
      ).tap { |actionable|
        actionable.default_action = actionable.actions.first
      }
    }

    let(:source) {
      double('Metasploit Module instance', default_action: source_default_action_name)
    }

    context 'with #source_default_action_name' do
      let(:source_default_action_name) {
        FactoryGirl.generate :metasploit_cache_actionable_action_name
      }

      context 'with name of member of destination.actions matching' do
        let!(:expected_default_action) {
          destination.actions.build(
              name: source_default_action_name
          )
        }

        it 'assigns matching member to destination.default_action' do
          expect {
            update_default_action
          }.to change(destination, :default_action).to(expected_default_action)
        end
      end

      context 'without name of member of destination.actions matching' do
        it 'sets destination.default_action to nil' do
          expect {
            update_default_action
          }.to change(destination, :default_action).to(nil)
        end
      end
    end

    context 'without #source_default_action_name' do
      let(:source_default_action_name) {
        nil
      }

      it 'sets destination.default_action to nil' do
        expect {
          update_default_action
        }.to change(destination, :default_action).to(nil)
      end
    end
  end
end