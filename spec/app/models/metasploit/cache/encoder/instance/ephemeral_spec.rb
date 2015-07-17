RSpec.describe Metasploit::Cache::Encoder::Instance::Ephemeral do
  context 'resurrecting attributes' do
    context '#encoder_instance' do
      subject(:encoder_instance) {
        encoder_instance_ephemeral.encoder_instance
      }

      #
      # lets
      #

      let(:encoder_instance_ephemeral) {
        described_class.new(
            encoder_metasploit_module_instance: encoder_metasploit_module_instance
        )
      }

      let(:metasploit_class) {
        double(
            'encoder Metasploit Module class',
            ephemeral_cache_by_source: {},
            real_path_sha1_hex_digest: existing_encoder_instance.encoder_class.ancestor.real_path_sha1_hex_digest
        )
      }

      let(:encoder_metasploit_module_instance) {
        double('encoder Metasploit Module instance').tap { |instance|
          allow(instance).to receive(:class).and_return(metasploit_class)
        }
      }

      #
      # let!s
      #

      let!(:existing_encoder_instance) {
        FactoryGirl.create(:metasploit_cache_encoder_instance)
      }

      #
      # Callbacks
      #

      before(:each) do
        metasploit_class.ephemeral_cache_by_source[:ancestor] = metasploit_class
      end

      it { is_expected.to be_a Metasploit::Cache::Encoder::Instance }

      it 'has #encoder_class matching pre-existing Metasploit::Cache::Encoder::Class' do
        expect(encoder_instance.encoder_class).to eq(existing_encoder_instance.encoder_class)
      end
    end
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:logger) }
    it { is_expected.to validate_presence_of(:encoder_metasploit_module_instance) }
  end

  context '#persist' do
    subject(:persist) {
      encoder_instance_ephemeral.persist(*args)
    }

    let(:encoder_instance_ephemeral) {
      described_class.new(
          logger: logger,
          encoder_metasploit_module_instance: encoder_metasploit_module_instance
      )
    }

    let(:encoder_metasploit_module_instance) {
      double('encoder Metasploit Module instance').tap { |instance|
        allow(instance).to receive(:class).and_return(metasploit_class)

        architecture_abbreviation = FactoryGirl.generate :metasploit_cache_architecture_abbreviation

        allow(instance).to receive(:arch).and_return([architecture_abbreviation])

        author = double('Metasploit Module instance author')
        author_name = FactoryGirl.generate :metasploit_cache_author_name
        email_address_domain = FactoryGirl.generate :metasploit_cache_email_address_domain
        email_address_local = FactoryGirl.generate :metasploit_cache_email_address_local
        email_address_full = "#{email_address_local}@#{email_address_domain}"

        allow(author).to receive(:name).and_return(author_name)
        allow(author).to receive(:email).and_return(email_address_full)

        allow(instance).to receive(:author).and_return([author])

        description = FactoryGirl.generate :metasploit_cache_encoder_instance_description

        allow(instance).to receive(:description).and_return(description)

        name = FactoryGirl.generate :metasploit_cache_encoder_instance_name

        allow(instance).to receive(:name).and_return(name)

        license_abbreviation = FactoryGirl.generate :metasploit_cache_license_abbreviation

        allow(instance).to receive(:license).and_return(license_abbreviation)

        platform = double('Platform', full_name: 'Windows XP')
        platform_list = double('Platform List', platforms: [platform])

        allow(instance).to receive(:platform).and_return(platform_list)
      }
    }

    let(:logger) {
      ActiveSupport::TaggedLogging.new(
          Logger.new(string_io)
      )
    }

    let(:string_io) {
      StringIO.new
    }

    context 'with :to' do
      let(:args) {
        [
            {
                to: encoder_instance
            }
        ]
      }

      let(:encoder_instance) {
        FactoryGirl.build(
            :metasploit_cache_encoder_instance,
            architecturable_architecture_count: 0,
            contribution_count: 0,
            description: nil,
            licensable_license_count: 0,
            platformable_platform_count: 0,
            name: nil
        )
      }

      let(:metasploit_class) {
        double(
            'encoder Metasploit Module class',
            ephemeral_cache_by_source: {}
        )
      }

      it 'does not access default #encoder_instance' do
        expect(encoder_instance_ephemeral).not_to receive(:encoder_instance)

        persist
      end

      it 'uses :to' do
        expect(encoder_instance).to receive(:batched_save).and_call_original

        persist
      end

      context 'batched save' do
        context 'failure' do
          before(:each) do
            encoder_instance.valid?

            expect(encoder_instance).to receive(:batched_save).and_return(false)
          end

          it 'tags log with Metasploit::Cache::Module::Ancestor#real_path' do
            persist

            expect(string_io.string).to include("[#{encoder_instance.encoder_class.ancestor.real_pathname.to_s}]")
          end

          it 'logs validation errors' do
            persist

            full_error_messages = encoder_instance.errors.full_messages.to_sentence

            expect(full_error_messages).not_to be_blank
            expect(string_io.string).to include("Could not be persisted to #{encoder_instance.class}: #{full_error_messages}")
          end
        end

        context 'success' do
          specify {
            expect {
              persist
            }.to change(Metasploit::Cache::Encoder::Instance, :count).by(1)
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

      let(:metasploit_class) {
        double(
            'encoder Metasploit Module class',
            ephemeral_cache_by_source: {},
            real_path_sha1_hex_digest: existing_encoder_instance.encoder_class.ancestor.real_path_sha1_hex_digest
        )
      }

      #
      # let!s
      #

      let!(:existing_encoder_instance) {
        FactoryGirl.create(:metasploit_cache_encoder_instance)
      }

      #
      # Callbacks
      #

      before(:each) do
        metasploit_class.ephemeral_cache_by_source[:ancestor] = metasploit_class
      end

      it 'defaults to #encoder_instance' do
        expect(encoder_instance_ephemeral).to receive(:encoder_instance).and_call_original

        persist
      end

      it 'uses #batched_save' do
        expect(encoder_instance_ephemeral.encoder_instance).to receive(:batched_save).and_call_original

        persist
      end
    end
  end
end