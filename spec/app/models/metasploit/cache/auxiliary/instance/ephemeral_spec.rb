RSpec.describe Metasploit::Cache::Auxiliary::Instance::Ephemeral do
  context 'resurrecting attributes' do
    context '#auxiliary_instance' do
      subject(:auxiliary_instance) {
        auxiliary_instance_ephemeral.auxiliary_instance
      }

      #
      # lets
      #

      let(:auxiliary_instance_ephemeral) {
        described_class.new(
            auxiliary_metasploit_module_instance: auxiliary_metasploit_module_instance
        )
      }

      let(:metasploit_class) {
        double(
            'auxiliary Metasploit Module class',
            ephemeral_cache_by_source: {},
            real_path_sha1_hex_digest: existing_auxiliary_instance.auxiliary_class.ancestor.real_path_sha1_hex_digest
        )
      }

      let(:auxiliary_metasploit_module_instance) {
        double('auxiliary Metasploit Module instance').tap { |instance|
          allow(instance).to receive(:class).and_return(metasploit_class)
        }
      }

      #
      # let!s
      #

      let!(:existing_auxiliary_instance) {
        FactoryGirl.create(:metasploit_cache_auxiliary_instance)
      }

      #
      # Callbacks
      #

      before(:each) do
        metasploit_class.ephemeral_cache_by_source[:ancestor] = metasploit_class
      end

      it { is_expected.to be_a Metasploit::Cache::Auxiliary::Instance }

      it 'has #auxiliary_class matching pre-existing Metasploit::Cache::Auxiliary::Class' do
        expect(auxiliary_instance.auxiliary_class).to eq(existing_auxiliary_instance.auxiliary_class)
      end
    end
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:logger) }
    it { is_expected.to validate_presence_of(:auxiliary_metasploit_module_instance) }
  end

  context '#persist' do
    subject(:persist) {
      auxiliary_instance_ephemeral.persist(*args)
    }

    let(:auxiliary_instance_ephemeral) {
      described_class.new(
          logger: logger,
          auxiliary_metasploit_module_instance: auxiliary_metasploit_module_instance
      )
    }

    let(:auxiliary_metasploit_module_instance) {
      double('auxiliary Metasploit Module instance').tap { |instance|
        allow(instance).to receive(:class).and_return(metasploit_class)

        author = double('Metasploit Module instance author')
        author_name = FactoryGirl.generate :metasploit_cache_author_name
        email_address_domain = FactoryGirl.generate :metasploit_cache_email_address_domain
        email_address_local = FactoryGirl.generate :metasploit_cache_email_address_local
        email_address_full = "#{email_address_local}@#{email_address_domain}"

        allow(author).to receive(:name).and_return(author_name)
        allow(author).to receive(:email).and_return(email_address_full)

        action = double('auxiliary Metasploit Module instance action')
        default_action_name = FactoryGirl.generate :metasploit_cache_module_action_name
        description = FactoryGirl.generate :metasploit_cache_auxiliary_instance_description
        name = FactoryGirl.generate :metasploit_cache_auxiliary_instance_name
        license_abbreviation = FactoryGirl.generate :metasploit_cache_license_abbreviation
        stance = FactoryGirl.generate :metasploit_cache_module_stance

        allow(action).to receive(:name).and_return(default_action_name)

        allow(instance).to receive(:actions).and_return([action])
        allow(instance).to receive(:authors).and_return([author])
        allow(instance).to receive(:default_action).and_return(default_action_name)
        allow(instance).to receive(:description).and_return(description)
        allow(instance).to receive(:license).and_return(license_abbreviation)
        allow(instance).to receive(:name).and_return(name)
        allow(instance).to receive(:stance).and_return(stance)
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
                to: auxiliary_instance
            }
        ]
      }

      let(:auxiliary_instance) {
        FactoryGirl.build(
            :metasploit_cache_auxiliary_instance,
            action_count: 0,
            contribution_count: 0,
            description: nil,
            licensable_license_count: 0,
            name: nil,
            stance: nil
        )
      }

      let(:metasploit_class) {
        double(
            'auxiliary Metasploit Module class',
            ephemeral_cache_by_source: {}
        )
      }

      it 'does not access default #auxiliary_instance' do
        expect(auxiliary_instance_ephemeral).not_to receive(:auxiliary_instance)

        persist
      end

      it 'uses :to' do
        expect(auxiliary_instance).to receive(:batched_save).and_call_original

        persist
      end

      context 'batched save' do
        context 'failure' do
          before(:each) do
            auxiliary_instance.valid?

            expect(auxiliary_instance).to receive(:batched_save).and_return(false)
          end

          it 'tags log with Metasploit::Cache::Module::Ancestor#real_path' do
            persist

            expect(string_io.string).to include("[#{auxiliary_instance.auxiliary_class.ancestor.real_pathname.to_s}]")
          end

          it 'logs validation errors' do
            persist

            full_error_messages = auxiliary_instance.errors.full_messages.to_sentence

            expect(full_error_messages).not_to be_blank
            expect(string_io.string).to include("Could not be persisted to #{auxiliary_instance.class}: #{full_error_messages}")
          end
        end

        context 'success' do
          specify {
            expect {
              persist
            }.to change(Metasploit::Cache::Auxiliary::Instance, :count).by(1)
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
            'auxiliary Metasploit Module class',
            ephemeral_cache_by_source: {},
            real_path_sha1_hex_digest: existing_auxiliary_instance.auxiliary_class.ancestor.real_path_sha1_hex_digest
        )
      }

      #
      # let!s
      #

      let!(:existing_auxiliary_instance) {
        FactoryGirl.create(:metasploit_cache_auxiliary_instance)
      }

      #
      # Callbacks
      #

      before(:each) do
        metasploit_class.ephemeral_cache_by_source[:ancestor] = metasploit_class
      end

      it 'defaults to #auxiliary_instance' do
        expect(auxiliary_instance_ephemeral).to receive(:auxiliary_instance).and_call_original

        persist
      end

      it 'uses #batched_save' do
        expect(auxiliary_instance_ephemeral.auxiliary_instance).to receive(:batched_save).and_call_original

        persist
      end
    end
  end
end