RSpec.describe Metasploit::Cache::Payload::Stager::Ancestor::Persister::Handler do
  context 'build_added' do
    subject(:build_added) {
      described_class.build_added(
          destination: destination,
          destination_attributes: destination_attributes,
          source_attributes: source_attributes
      )
    }

    context 'with pre-existing Metasploit::Cache::Payload::Stager::Ancestor#handler' do
      #
      # lets
      #

      let(:destination_attributes) {
        {
            handler: {
                type_alias: destination.handler.type_alias
            }
        }
      }

      #
      # let!s
      #

      let!(:destination) {
        FactoryGirl.create(:full_metasploit_cache_payload_stager_ancestor)
      }

      context 'with source responds to handler_type_alias' do
        let(:source_attributes) {
          {
              handler: {
                  type_alias: FactoryGirl.generate(:metasploit_cache_payload_stager_ancestor_handler_type_alias)
              }
          }
        }

        it 'does not update destination.handler.type_alias' do
          expect {
            build_added
          }.not_to change(destination.handler, :type_alias)
        end
      end

      context 'without source responds to handler_type_alias' do
        let(:source_attributes) {
          {
              handler: nil
          }
        }

        it 'does not update destination.handler.type_alias' do
          expect {
            build_added
          }.not_to change(destination.handler, :type_alias)
        end
      end
    end

    context 'without pre-existing Metasploit::Cache::Payload::Stager::Ancestor#handler' do
      let(:destination) {
        FactoryGirl.build(:metasploit_cache_payload_stager_ancestor)
      }

      let(:destination_attributes) {
        {
            handler: nil
        }
      }

      context 'with source responds to handler_type_alias' do
        let(:handler_type_alias) {
          FactoryGirl.generate(:metasploit_cache_payload_stager_ancestor_handler_type_alias)
        }

        let(:source_attributes) {
          {
              handler: {
                  type_alias: handler_type_alias
              }
          }
        }

        it 'builds destination.handler' do
          expect {
            build_added
          }.to change(destination, :handler).from(nil)
        end

        it 'sets destination.handler.type_alias to source.handler_type_alias' do
          expect(build_added.handler.type_alias).to eq(handler_type_alias)
        end
      end

      context 'without source responds to handler_type_alias' do
        let(:source_attributes) {
          {
              handler: nil
          }
        }

        it 'does not set destination.handler' do
          expect {
            build_added
          }.not_to change(destination, :handler).from(nil)
        end
      end
    end
  end

  context 'destination_attributes' do
    subject(:destination_attributes) {
      described_class.destination_attributes(destination)
    }

    context 'with Metasploit::Cache::Payload::Stager::Ancestor#handler' do
      let(:destination) {
        FactoryGirl.build(:full_metasploit_cache_payload_stager_ancestor)
      }

      it 'returns {handler: {type_alias: destination.handler.type_lias}' do
        expect(destination_attributes).to eq(
                                              {
                                                  handler: {
                                                      type_alias: destination.handler.type_alias
                                                  }
                                              }
                                          )
      end
    end

    context 'with Metasploit::Cache::Payload::Stager::Ancestor#handler' do
      let(:destination) {
        FactoryGirl.build(:metasploit_cache_payload_stager_ancestor)
      }

      it 'returns {handler: nil}' do
        expect(destination_attributes).to eq(
                                              {
                                                  handler: nil
                                              }
                                          )
      end
    end
  end

  context 'mark_removed_for_destruction' do
    subject(:mark_removed_for_destruction) {
      described_class.mark_removed_for_destruction(
          destination: destination,
          destination_attributes: destination_attributes,
          source_attributes: source_attributes
      )
    }

    context 'with new destination' do
      let(:destination) {
        FactoryGirl.build(:metasploit_cache_payload_stager_ancestor)
      }

      let(:destination_attributes) {
        {}
      }

      let(:source_attributes) {
        {}
      }

      it 'does not change destination' do
        expect {
          mark_removed_for_destruction
        }.not_to change(destination, :handler)
      end
    end

    context 'with persisted destination' do
      #
      # lets
      #

      let(:destination_attributes) {
        {
            handler: {
                type_alias: destination.handler.type_alias
            }
        }
      }

      #
      # let!s
      #

      let!(:destination) {
        FactoryGirl.create(:full_metasploit_cache_payload_stager_ancestor)
      }

      context 'with source responds to handler_type_alias' do
        let(:source_attributes) {
          {
              handler: {
                  type_alias: FactoryGirl.generate(:metasploit_cache_payload_stager_ancestor_handler_type_alias)
              }
          }
        }

        it 'does not mark destination.handler for removal' do
          mark_removed_for_destruction

          expect(destination.handler).not_to be_marked_for_destruction
        end
      end

      context 'without source responds to handler_type_alias' do
        let(:source_attributes) {
          {
              handler: nil
          }
        }

        it 'marks destination.handler for removal' do
          mark_removed_for_destruction

          expect(destination.handler).to be_marked_for_destruction
        end
      end
    end
  end

  context 'source_attributes' do
    subject(:source_attributes) {
      described_class.source_attributes(source)
    }

    context 'with source responds to handler_type_alias' do
      let(:handler_type_alias) {
        FactoryGirl.generate :metasploit_cache_payload_stager_ancestor_handler_type_alias
      }

      let(:source) {
        Module.new.tap { |mod|
          context_handler_type_alias = handler_type_alias

          mod.define_singleton_method(:handler_type_alias) {
            context_handler_type_alias
          }
        }
      }

      it 'returns {handler: {type_alias: source.handler_type_alias}}' do
        expect(source_attributes).to eq(
                                         {
                                             handler: {
                                                 type_alias: handler_type_alias
                                             }
                                         }
                                     )
      end
    end

    context 'without source responds to handler_type_alias' do
      let(:source) {
        Module.new
      }

      it 'returns {handler: nil}' do
        expect(source_attributes).to eq(
                                         {
                                             handler: nil
                                         }
                                     )
      end
    end
  end

  context 'synchronize' do
    subject(:synchronize) {
      described_class.synchronize(
          destination: destination,
          logger: nil,
          source: source
      )
    }

    context 'with new destination' do
      let(:destination) {
        FactoryGirl.build :metasploit_cache_payload_stager_ancestor
      }

      context 'with source responds to handler_type_alias' do
        let(:handler_type_alias) {
          FactoryGirl.generate :metasploit_cache_payload_stager_ancestor_handler_type_alias
        }

        let(:source) {
          Module.new.tap { |mod|
            context_handler_type_alias = handler_type_alias

            mod.define_singleton_method(:handler_type_alias) {
              context_handler_type_alias
            }
          }
        }

        it 'sets destination.handler' do
          expect {
            synchronize
          }.to change(destination, :handler).from(nil)
        end

        it 'sets destination.handler.type_alias with source.handler_type_alias' do
          synchronize

          expect(destination.handler.type_alias).to eq(handler_type_alias)
        end
      end

      context 'without source responds to handler_type_alias' do
        let(:source) {
          Module.new
        }

        it 'does not set destination.handler' do
          expect {
            synchronize
          }.not_to change(destination, :handler).from(nil)
        end
      end
    end

    context 'with persisted destination' do
      context 'with handler' do
        let!(:destination) {
          FactoryGirl.create(:full_metasploit_cache_payload_stager_ancestor)
        }

        context 'with source responds to handler_type_alias' do
          let(:handler_type_alias) {
            FactoryGirl.generate :metasploit_cache_payload_stager_ancestor_handler_type_alias
          }

          let(:source) {
            Module.new.tap { |mod|
              context_handler_type_alias = handler_type_alias

              mod.define_singleton_method(:handler_type_alias) {
                context_handler_type_alias
              }
            }
          }

          it 'changes destination.handler.type_alias to source.handler_type_alias' do
            expect {
              synchronize
            }.to change(destination.handler, :type_alias).to(handler_type_alias)
          end
        end

        context 'without source responds to handler_type_alias' do
          let(:source) {
            Module.new
          }

          it 'marks destination.handler for destruction' do
            expect {
              synchronize
            }.to change(destination.handler, :marked_for_destruction?).to(true)
          end
        end
      end

      context 'without handler' do
        let!(:destination) {
          FactoryGirl.create(:metasploit_cache_payload_stager_ancestor)
        }

        context 'with source responds to handler_type_alias' do
          let(:handler_type_alias) {
            FactoryGirl.generate :metasploit_cache_payload_stager_ancestor_handler_type_alias
          }

          let(:source) {
            Module.new.tap { |mod|
              context_handler_type_alias = handler_type_alias

              mod.define_singleton_method(:handler_type_alias) {
                context_handler_type_alias
              }
            }
          }

          it 'sets destination.handler' do
            expect {
              synchronize
            }.to change(destination, :handler).from(nil)
          end

          it 'sets destination.handler.type_alias with source.handler_type_alias' do
            synchronize

            expect(destination.handler.type_alias).to eq(handler_type_alias)
          end
        end

        context 'without source responds to handler_type_alias' do
          let(:source) {
            Module.new
          }

          it 'does not set destination.handler' do
            expect {
              synchronize
            }.not_to change(destination, :handler).from(nil)
          end
        end
      end
    end
  end

  context 'update_changed' do
    subject(:update_changed) {
      described_class.update_changed(
          destination: destination,
          destination_attributes: destination_attributes,
          source_attributes: source_attributes
      )
    }

    context 'with destination.handler' do
      let(:destination) {
        FactoryGirl.build(:full_metasploit_cache_payload_stager_ancestor)
      }

      let(:destination_attributes) {
        {
            handler: {
                type_alias: destination.handler.type_alias
            }
        }
      }

      context 'with source responds to handler_type_alias' do
        let(:handler_type_alias) {
          FactoryGirl.generate :metasploit_cache_payload_stager_ancestor_handler_type_alias
        }

        let(:source_attributes) {
          {
              handler: {
                  type_alias: handler_type_alias
              }
          }
        }

        it 'changes destination.handler.type_alias to source.handler_type_alias' do
          expect {
            update_changed
          }.to change(destination.handler, :type_alias).to(handler_type_alias)
        end
      end

      context 'without source responds to handler_type_alias' do
        let(:source_attributes) {
          {
              handler: nil
          }
        }

        it 'does not change destination.handler' do
          expect {
            update_changed
          }.not_to change(destination, :handler)
        end
      end
    end

    context 'without destination.handler' do
      let(:destination) {
        FactoryGirl.build(:metasploit_cache_payload_stager_ancestor)
      }

      let(:destination_attributes) {
        {
            handler: nil
        }
      }

      context 'with source responds to handler_type_alias' do
        let(:handler_type_alias) {
          FactoryGirl.generate :metasploit_cache_payload_stager_ancestor_handler_type_alias
        }

        let(:source_attributes) {
          {
              handler: {
                  type_alias: handler_type_alias
              }
          }
        }

        it 'does not create destination.handler' do
          expect {
            update_changed
          }.not_to change(destination, :handler).from(nil)
        end
      end

      context 'without source responds to handler_type_alias' do
        let(:source_attributes) {
          {
              handler: nil
          }
        }

        it 'does not change destination.handler' do
          expect {
            update_changed
          }.not_to change(destination, :handler)
        end
      end
    end
  end
end