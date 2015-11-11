RSpec.describe Metasploit::Cache::Payload::Stager::Ancestor::Persister, type: :model do
  include_context 'ActiveSupport::TaggedLogging'

  subject(:payload_stager_ancestor_persister) {
    described_class.new(
        ephemeral: metasploit_module,
        logger: logger,
        real_path_sha1_hex_digest: real_path_sha1_hex_digest
    )
  }

  let(:metasploit_module) {
    Module.new
  }

  context '#persist' do
    subject(:persist) {
      payload_stager_ancestor_persister.persist(*args)
    }

    context 'with :to' do
      let(:args) {
        [
            {
                to: payload_stager_ancestor
            }
        ]
      }

      let(:payload_stager_ancestor) {
        FactoryGirl.build(:metasploit_cache_payload_stager_ancestor)
      }

      let(:real_path_sha1_hex_digest) {
        payload_stager_ancestor.real_path_sha1_hex_digest
      }

      it 'does not access default #persistent' do
        expect(payload_stager_ancestor_persister).not_to receive(:persistent)

        persist
      end

      it 'uses :to' do
        expect(payload_stager_ancestor).to receive(:batched_save).and_call_original

        persist
      end

      context 'batched save' do
        context 'failure' do
          include_context 'ActiveSupport::TaggedLogging'

          #
          # lets
          #

          let(:payload_stager_ancestor) {
            super().tap { |payload_stager_ancestor|
              payload_stager_ancestor.relative_path = File.join('does', 'not', 'exist.rb')
            }
          }

          #
          # Callbacks
          #

          before(:each) do
            payload_stager_ancestor.valid?
            payload_stager_ancestor_persister.logger = logger
          end

          it 'tags log with Metasploit::Cache::Module::Ancestor#real_path' do
            persist

            expect(logger_string_io.string).to include("[#{payload_stager_ancestor.real_pathname.to_s}]")
          end

          it 'logs validation errors' do
            persist

            full_error_messages = payload_stager_ancestor.errors.full_messages.to_sentence

            expect(full_error_messages).not_to be_blank
            expect(logger_string_io.string).to include("Could not be persisted to Metasploit::Cache::Payload::Stager::Ancestor: #{full_error_messages}")
          end
        end

        context 'success' do
          context 'with handler_type_alias' do
            let(:handler_type_alias) {
              FactoryGirl.generate :metasploit_cache_payload_stager_ancestor_handler_type_alias
            }

            let(:metasploit_module) {
              Module.new.tap { |mod|
                context_handler_type_alias = handler_type_alias

                mod.define_singleton_method(:handler_type_alias) {
                  context_handler_type_alias
                }
              }
            }

            specify {
              expect {
                persist
              }.to change(Metasploit::Cache::Payload::Stager::Ancestor, :count).by(1)
            }

            context 'without pre-existing Metasploit::Cache::Payload::Stager::Ancestor#handler' do
              let!(:payload_stager_ancestor) {
                FactoryGirl.create(:metasploit_cache_payload_stager_ancestor)
              }

              it 'sets handler' do
                expect {
                  persist
                }.to change {
                       payload_stager_ancestor.reload.handler
                     }.from(nil)
              end

              it 'sets handler.type_alias to handler_type_alias' do
                persist

                expect(payload_stager_ancestor.handler.type_alias).to eq(handler_type_alias)
              end
            end
          end

          context 'without handler_type_alias' do
            specify {
              expect {
                persist
              }.to change(Metasploit::Cache::Payload::Stager::Ancestor, :count).by(1)
            }

            context 'with pre-existing Metasploit::Cache::Payload::Stager::Ancestor#handler' do
              let!(:payload_stager_ancestor) {
                FactoryGirl.create(:full_metasploit_cache_payload_stager_ancestor)
              }

              it 'unsets handler' do
                expect {
                  persist
                }.to change {
                       payload_stager_ancestor.reload.handler
                     }.to(nil)
              end
            end
          end
        end
      end
    end

    context 'without :to' do
      let(:args) {
        []
      }

      let(:existing_payload_stager_ancestor) {
        FactoryGirl.create(:metasploit_cache_payload_stager_ancestor)
      }

      let(:real_path_sha1_hex_digest) {
        existing_payload_stager_ancestor.real_path_sha1_hex_digest
      }

      it 'defaults to #persistent' do
        expect(payload_stager_ancestor_persister).to receive(:persistent).and_call_original

        persist
      end

      it 'uses #persistent' do
        expect(payload_stager_ancestor_persister.persistent).to receive(:batched_save).and_call_original

        persist
      end
    end
  end
end