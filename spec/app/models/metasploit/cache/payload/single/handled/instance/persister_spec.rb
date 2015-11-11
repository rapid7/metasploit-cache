RSpec.describe Metasploit::Cache::Payload::Single::Handled::Instance::Persister, type: :model do
  it_should_behave_like 'Metasploit::Cache::Module::Persister'

  context 'resurrecting attributes' do
    context '#persistent' do
      include_context ':metasploit_cache_payload_handler_module'
      include_context 'Metasploit::Cache::Spec::Unload.unload'

      subject(:persistent) {
        payload_single_handled_instance_persister.persistent
      }

      #
      # lets
      #

      let(:existing_payload_single_handled_instance) {
        FactoryGirl.create(
            :metasploit_cache_payload_single_handled_instance,
            payload_single_handled_class_payload_single_unhandled_instance_handler_load_pathname: metasploit_cache_payload_handler_module_load_pathname
        )
      }

      let(:payload_single_handled_instance_persister) {
        described_class.new(
            ephemeral: double(
                'payload single handled Metasploit Module instance',
                class: double(
                    'payload single handled Metasploit Module class',
                    persister_by_source: {
                        ancestor: Metasploit::Cache::Module::Ancestor::Persister.new(
                            real_path_sha1_hex_digest: existing_payload_single_handled_instance.payload_single_handled_class.payload_single_unhandled_instance.payload_single_unhandled_class.ancestor.real_path_sha1_hex_digest
                        )
                    }
                )
            )
        )
      }

      #
      # Callbacks
      #

      before(:each) do
        # create now that load_path is setup
        existing_payload_single_handled_instance
      end

      it 'is an instance of Metasploit::Cache::Payload::Single::Handled::Instance' do
        expect(persistent).to be_a Metasploit::Cache::Payload::Single::Handled::Instance
      end

      context 'Metasploit::Cache::Payload::Single::Handled::Instance#payload_single_handled_class' do
        subject(:payload_single_handled_class) {
          persistent.payload_single_handled_class
        }

        it { is_expected.to be_persisted }

        context 'Metasploit::Cache::Payload::Single::Handled::Class#payload_single_unhandled_instance' do
          subject(:payload_single_unhandled_instance) {
            payload_single_handled_class.payload_single_unhandled_instance
          }

          it { is_expected.to be_persisted }

          context 'Metasploit::Cache::Payload::Single::Unhandled::Instance#payload_single_unhandled_class' do
            subject(:payload_single_unhandled_class) {
              payload_single_unhandled_instance.payload_single_unhandled_class
            }

            it { is_expected.to be_persisted }

            context 'Metasploit::Cache::Payload::Single::Unhandled::Class#ancestor' do
              subject(:ancestor) {
                payload_single_unhandled_class.ancestor
              }

              it { is_expected.to be_persisted }
            end
          end
        end
      end
    end
  end

  context '#persist' do
    include_context 'ActiveSupport::TaggedLogging'
    include_context ':metasploit_cache_payload_handler_module'
    include_context 'Metasploit::Cache::Spec::Unload.unload'

    subject(:persist) do
      payload_single_handled_instance_persister.persist(*args)
    end

    #
    # lets
    #

    let(:payload_single_handled_instance_persister) {
      described_class.new(
          ephemeral: double(
              'payload single handled Metasploit Module instance',
              class: double(
                  'payload single handled Metasploit Module class',
                  persister_by_source: {
                      ancestor: Metasploit::Cache::Module::Ancestor::Persister.new(
                        real_path_sha1_hex_digest: payload_single_ancestor.real_path_sha1_hex_digest
                    )
                  }
              )
          ),
          logger: logger
      )
    }

    context 'with :to' do
      #
      # lets
      #

      let(:args) {
        [
            {
                to: passed_payload_single_handled_instance
            }
        ]
      }

      let(:passed_payload_single_handled_instance) {
        FactoryGirl.build(
            :metasploit_cache_payload_single_handled_instance,
            payload_single_handled_class_payload_single_unhandled_instance_handler_load_pathname: metasploit_cache_payload_handler_module_load_pathname
        )
      }

      let(:payload_single_ancestor) {
        passed_payload_single_handled_instance.payload_single_handled_class.payload_single_unhandled_instance.payload_single_unhandled_class.ancestor
      }

      it 'does not access default #persistent' do
        expect(payload_single_handled_instance_persister).not_to receive(:persistent)

        persist
      end

      it 'uses :to' do
        expect(passed_payload_single_handled_instance).to receive(:batched_save).and_call_original

        persist
      end

      context 'batched save' do
        context 'failure' do
          #
          # Callbacks
          #

          before(:each) do
            passed_payload_single_handled_instance.valid?

            expect(passed_payload_single_handled_instance).to receive(:batched_save).and_return(false)
          end

          it 'tags log with Metasploit::Cache::Payload::Single::Handled::Instance#payload_single_unhandled_instance ' \
             'Metasploit::Cache::Payload::Single::Unhandled::Instance#payload_single_unhandled_instance ' \
             'Metasploit::Cache::Payload::Single::UnHandled::Instance#ancestor Metasploit::Cache::Module::Ancestor#real_path' do
            persist

            expect(logger_string_io.string).to include("[#{payload_single_ancestor.real_pathname.to_s}]")
          end

          it 'logs validation errors' do
            # Right now, there are no validation errors because there are no attributes on
            # Metasploit::Cache::Payload::Staged::Class and the associations are already set.
            expect(passed_payload_single_handled_instance.errors.full_messages.to_sentence).to be_blank

            # ... so, fake some validation errors
            passed_payload_single_handled_instance.errors.add(:base, :invalid)

            persist

            full_error_messages = passed_payload_single_handled_instance.errors.full_messages.to_sentence

            expect(full_error_messages).not_to be_blank
            expect(logger_string_io.string).to include("Could not be persisted to #{passed_payload_single_handled_instance.class}: #{full_error_messages}")
          end
        end

        context 'success' do
          specify {
            expect {
              persist
            }.to change(Metasploit::Cache::Payload::Single::Handled::Instance, :count).by(1)
          }
        end
      end
    end

    context 'without :to' do
      #
      # lets
      #

      let(:args) {
        []
      }

      let(:payload_single_ancestor) {
        existing_payload_single_handled_instance.payload_single_handled_class.payload_single_unhandled_instance.payload_single_unhandled_class.ancestor
      }

      #
      # let!s
      #

      let!(:existing_payload_single_handled_instance) {
        FactoryGirl.create(
            :metasploit_cache_payload_single_handled_instance,
            payload_single_handled_class_payload_single_unhandled_instance_handler_load_pathname: metasploit_cache_payload_handler_module_load_pathname
        )
      }

      it 'defaults to #persistent' do
        expect(payload_single_handled_instance_persister).to receive(:persistent).and_call_original

        persist
      end

      it 'uses #batched_save' do
        expect(payload_single_handled_instance_persister.persistent).to receive(:batched_save).and_call_original

        persist
      end
    end
  end
end