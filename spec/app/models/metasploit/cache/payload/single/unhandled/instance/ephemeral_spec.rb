RSpec.describe Metasploit::Cache::Payload::Single::Unhandled::Instance::Ephemeral, type: :model do
  context 'resurrecting attributes' do
    context '#persistent' do
      include_context ':metasploit_cache_payload_handler_module'
      include_context 'Metasploit::Cache::Spec::Unload.unload'

      subject(:persistent) {
        payload_single_unhandled_instance_ephemeral.persistent
      }

      #
      # lets
      #

      let(:existing_payload_single_unhandled_instance) {
        FactoryGirl.create(
            :full_metasploit_cache_payload_single_unhandled_instance,
            handler_load_pathname: metasploit_cache_payload_handler_module_load_pathname
        )
      }

      let(:payload_single_unhandled_instance_ephemeral) {
        described_class.new(
            metasploit_module_instance: metasploit_module_instance
        )
      }

      let(:metasploit_class) {
        double(
            'payload single Metasploit Module class',
            ephemeral_cache_by_source: {},
            real_path_sha1_hex_digest: existing_payload_single_unhandled_instance.payload_single_unhandled_class.ancestor.real_path_sha1_hex_digest
        )
      }

      let(:metasploit_module_instance) {
        double('payload single Metasploit Module instance').tap { |instance|
          allow(instance).to receive(:class).and_return(metasploit_class)
        }
      }

      #
      # Callbacks
      #

      before(:each) do
        existing_payload_single_unhandled_instance

        metasploit_class.ephemeral_cache_by_source[:ancestor] = metasploit_class
      end

      it { is_expected.to be_a Metasploit::Cache::Payload::Single::Unhandled::Instance }

      it 'has #payload_single_unhandled_class matching pre-existing Metasploit::Cache::Payload::Single::Unhandled::Class' do
        expect(persistent.payload_single_unhandled_class).to eq(existing_payload_single_unhandled_instance.payload_single_unhandled_class)
      end
    end
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:logger) }
    it { is_expected.to validate_presence_of(:metasploit_module_instance) }
  end

  context '#persist' do
    include_context 'ActiveSupport::TaggedLogging'

    subject(:persist) {
      payload_single_unhandled_instance_ephemeral.persist(*args)
    }

    let(:payload_single_unhandled_instance_ephemeral) {
      described_class.new(
          logger: logger,
          metasploit_module_instance: metasploit_module_instance
      )
    }

    let(:metasploit_module_instance) {
      double(
          'payload single Metasploit Module instance',
          arch: [
              FactoryGirl.generate(:metasploit_cache_architecture_abbreviation)
          ],
          author: [
              double(
                  'Metasploit Module instance author',
                  email: "#{FactoryGirl.generate(:metasploit_cache_email_address_local)}@#{FactoryGirl.generate(:metasploit_cache_email_address_domain)}",
                  name: FactoryGirl.generate(:metasploit_cache_author_name)
              )
          ],
          class: metasploit_class,
          description: FactoryGirl.generate(:metasploit_cache_payload_single_unhandled_instance_description),
          disclosure_date: Date.today,
          handler_klass: double(
              'payload Metasploit Module handler',
              FactoryGirl.attributes_for(:metasploit_cache_payload_handler)
          ),
          name: FactoryGirl.generate(:metasploit_cache_payload_single_unhandled_instance_name),
          license: FactoryGirl.generate(:metasploit_cache_license_abbreviation),
          platform: double(
              'Platform List',
              platforms: [
                  double('Platform', realname: 'Windows XP')
              ]
          ),
          privileged: true
      )
    }

    context 'with :to' do
      let(:args) {
        [
            {
                to: payload_single_unhandled_instance
            }
        ]
      }

      let(:payload_single_unhandled_class) {
        FactoryGirl.create(:metasploit_cache_payload_single_unhandled_class)
      }

      let(:payload_single_unhandled_instance) {
        payload_single_unhandled_class.build_payload_single_unhandled_instance
      }

      let(:metasploit_class) {
        double(
            'payload single Metasploit Module class',
            ephemeral_cache_by_source: {}
        )
      }

      it 'does not access default #persistent' do
        expect(payload_single_unhandled_instance_ephemeral).not_to receive(:persistent)

        persist
      end

      it 'uses :to' do
        expect(payload_single_unhandled_instance).to receive(:batched_save).and_call_original

        persist
      end

      context 'batched save' do
        context 'failure' do
          before(:each) do
            payload_single_unhandled_instance.valid?

            expect(payload_single_unhandled_instance).to receive(:batched_save).and_return(false)
          end

          it 'tags log with Metasploit::Cache::Module::Ancestor#real_path' do
            persist

            expect(logger_string_io.string).to include("[#{payload_single_unhandled_instance.payload_single_unhandled_class.ancestor.real_pathname.to_s}]")
          end

          it 'logs validation errors' do
            persist

            full_error_messages = payload_single_unhandled_instance.errors.full_messages.to_sentence

            expect(full_error_messages).not_to be_blank
            expect(logger_string_io.string).to include("Could not be persisted to #{payload_single_unhandled_instance.class}: #{full_error_messages}")
          end
        end

        context 'success' do
          specify {
            expect {
              persist
            }.to change(Metasploit::Cache::Payload::Single::Unhandled::Instance, :count).by(1)
          }
        end
      end
    end

    context 'without :to' do
      include_context ':metasploit_cache_payload_handler_module'
      include_context 'Metasploit::Cache::Spec::Unload.unload'

      #
      # lets
      #

      let(:args) {
        []
      }

      let(:existing_payload_single_unhandled_instance) {
        FactoryGirl.create(
            :full_metasploit_cache_payload_single_unhandled_instance,
            handler_load_pathname: metasploit_cache_payload_handler_module_load_pathname
        )
      }

      let(:metasploit_class) {
        double(
            'payload single Metasploit Module class',
            ephemeral_cache_by_source: {},
            real_path_sha1_hex_digest: existing_payload_single_unhandled_instance.payload_single_unhandled_class.ancestor.real_path_sha1_hex_digest
        )
      }

      #
      # Callbacks
      #

      before(:each) do
        existing_payload_single_unhandled_instance

        metasploit_class.ephemeral_cache_by_source[:ancestor] = metasploit_class
      end

      it 'defaults to #persistent' do
        expect(payload_single_unhandled_instance_ephemeral).to receive(:persistent).and_call_original

        persist
      end

      it 'uses #batched_save' do
        expect(payload_single_unhandled_instance_ephemeral.persistent).to receive(:batched_save).and_call_original

        persist
      end
    end
  end
end