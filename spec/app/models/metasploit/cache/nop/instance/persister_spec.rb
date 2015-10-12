RSpec.describe Metasploit::Cache::Nop::Instance::Persister, type: :model do
  context 'resurrecting attributes' do
    context '#nop_instance' do
      subject(:persistent) {
        nop_instance_persister.persistent
      }

      #
      # lets
      #

      let(:nop_instance_persister) {
        described_class.new(
            metasploit_module_instance: metasploit_module_instance
        )
      }

      let(:metasploit_class) {
        double(
            'nop Metasploit Module class',
            persister_by_source: {},
            real_path_sha1_hex_digest: existing_nop_instance.nop_class.ancestor.real_path_sha1_hex_digest
        )
      }

      let(:metasploit_module_instance) {
        double('nop Metasploit Module instance').tap { |instance|
          allow(instance).to receive(:class).and_return(metasploit_class)
        }
      }

      #
      # let!s
      #

      let!(:existing_nop_instance) {
        FactoryGirl.create(:full_metasploit_cache_nop_instance)
      }

      #
      # Callbacks
      #

      before(:each) do
        metasploit_class.persister_by_source[:ancestor] = metasploit_class
      end

      it { is_expected.to be_a Metasploit::Cache::Nop::Instance }

      it 'has #nop_class matching pre-existing Metasploit::Cache::Nop::Class' do
        expect(persistent.nop_class).to eq(existing_nop_instance.nop_class)
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
      nop_instance_persister.persist(*args)
    }

    let(:nop_instance_persister) {
      described_class.new(
          logger: logger,
          metasploit_module_instance: metasploit_module_instance
      )
    }

    let(:metasploit_module_instance) {
      double('nop Metasploit Module instance').tap { |instance|
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

        allow(instance).to receive(:default_target).and_return(nil)

        description = FactoryGirl.generate :metasploit_cache_nop_instance_description

        allow(instance).to receive(:description).and_return(description)

        allow(instance).to receive(:disclosure_date).and_return(Date.today)

        name = FactoryGirl.generate :metasploit_cache_nop_instance_name

        allow(instance).to receive(:name).and_return(name)

        license_abbreviation = FactoryGirl.generate :metasploit_cache_license_abbreviation

        allow(instance).to receive(:license).and_return(license_abbreviation)

        platform = double('Platform', realname: 'Windows XP')
        platform_list = double('Platform List', platforms: [platform])

        allow(instance).to receive(:platform).and_return(platform_list)

        authority = FactoryGirl.generate :seeded_metasploit_cache_authority

        reference = double(
            'nop Metasploit Module instance reference',
            ctx_id: authority.abbreviation,
            ctx_val: FactoryGirl.generate(:metasploit_cache_reference_designation)
        )

        allow(instance).to receive(:references).and_return([reference])

        allow(instance).to receive(:stance).and_return(Metasploit::Cache::Module::Stance::AGGRESSIVE)
      }
    }

    context 'with :to' do
      let(:args) {
        [
            {
                to: nop_instance
            }
        ]
      }

      let(:nop_class) {
        FactoryGirl.create(:full_metasploit_cache_nop_class)
      }

      let(:nop_instance) {
        nop_class.build_nop_instance
      }

      let(:metasploit_class) {
        double(
            'nop Metasploit Module class',
            persister_by_source: {}
        )
      }

      it 'does not access default #persistent' do
        expect(nop_instance_persister).not_to receive(:persistent)

        persist
      end

      it 'uses :to' do
        expect(nop_instance).to receive(:batched_save).and_call_original

        persist
      end

      context 'batched save' do
        context 'failure' do
          before(:each) do
            nop_instance.valid?

            expect(nop_instance).to receive(:batched_save).and_return(false)
          end

          it 'tags log with Metasploit::Cache::Module::Ancestor#real_path' do
            persist

            expect(logger_string_io.string).to include("[#{nop_instance.nop_class.ancestor.real_pathname.to_s}]")
          end

          it 'logs validation errors' do
            persist

            full_error_messages = nop_instance.errors.full_messages.to_sentence

            expect(full_error_messages).not_to be_blank
            expect(logger_string_io.string).to include("Could not be persisted to #{nop_instance.class}: #{full_error_messages}")
          end
        end

        context 'success' do
          specify {
            expect {
              persist
            }.to change(Metasploit::Cache::Nop::Instance, :count).by(1)
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
            'nop Metasploit Module class',
            persister_by_source: {},
            real_path_sha1_hex_digest: existing_nop_instance.nop_class.ancestor.real_path_sha1_hex_digest
        )
      }

      #
      # let!s
      #

      let!(:existing_nop_instance) {
        FactoryGirl.create(:full_metasploit_cache_nop_instance)
      }

      #
      # Callbacks
      #

      before(:each) do
        metasploit_class.persister_by_source[:ancestor] = metasploit_class
      end

      it 'defaults to #persistent' do
        expect(nop_instance_persister).to receive(:persistent).and_call_original

        persist
      end

      it 'uses #batched_save' do
        expect(nop_instance_persister.persistent).to receive(:batched_save).and_call_original

        persist
      end
    end
  end
end