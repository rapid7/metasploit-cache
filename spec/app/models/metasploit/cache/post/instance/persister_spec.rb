RSpec.describe Metasploit::Cache::Post::Instance::Persister, type: :model do
  context 'resurrecting attributes' do
    context '#persistent' do
      subject(:persistent) {
        module_ancestor_persister.persistent
      }

      #
      # lets
      #

      let(:module_ancestor_persister) {
        described_class.new(
            metasploit_module_instance: metasploit_module_instance
        )
      }

      let(:metasploit_class) {
        double(
            'post Metasploit Module class',
            persister_by_source: {},
            real_path_sha1_hex_digest: existing_post_instance.post_class.ancestor.real_path_sha1_hex_digest
        )
      }

      let(:metasploit_module_instance) {
        double('post Metasploit Module instance').tap { |instance|
          allow(instance).to receive(:class).and_return(metasploit_class)
        }
      }

      #
      # let!s
      #

      let!(:existing_post_instance) {
        FactoryGirl.create(:full_metasploit_cache_post_instance)
      }

      #
      # Callbacks
      #

      before(:each) do
        metasploit_class.persister_by_source[:ancestor] = metasploit_class
      end

      it { is_expected.to be_a Metasploit::Cache::Post::Instance }

      it 'has #post_class matching pre-existing Metasploit::Cache::Post::Class' do
        expect(persistent.post_class).to eq(existing_post_instance.post_class)
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
      module_ancestor_persister.persist(*args)
    }

    let(:module_ancestor_persister) {
      described_class.new(
          logger: logger,
          metasploit_module_instance: metasploit_module_instance
      )
    }

    let(:metasploit_module_instance) {
      double('post Metasploit Module instance').tap { |instance|
        allow(instance).to receive(:class).and_return(metasploit_class)

        action = double('auxiliary Metasploit Module instance action')
        default_action_name = FactoryGirl.generate :metasploit_cache_actionable_action_name

        allow(action).to receive(:name).and_return(default_action_name)
        allow(instance).to receive(:actions).and_return([action])

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

        allow(instance).to receive(:default_action).and_return(default_action_name)

        description = FactoryGirl.generate :metasploit_cache_post_instance_description

        allow(instance).to receive(:description).and_return(description)

        allow(instance).to receive(:disclosure_date).and_return(Date.today)

        name = FactoryGirl.generate :metasploit_cache_post_instance_name

        allow(instance).to receive(:name).and_return(name)

        license_abbreviation = FactoryGirl.generate :metasploit_cache_license_abbreviation

        allow(instance).to receive(:license).and_return(license_abbreviation)

        platform = double('Platform', realname: 'Windows XP')
        platform_list = double('Platform List', platforms: [platform])

        allow(instance).to receive(:platform).and_return(platform_list)

        allow(instance).to receive(:privileged).and_return(true)

        authority = FactoryGirl.generate :seeded_metasploit_cache_authority

        reference = double(
            'exploit Metasploit Module instance reference',
            ctx_id: authority.abbreviation,
            ctx_val: FactoryGirl.generate(:metasploit_cache_reference_designation)
        )

        allow(instance).to receive(:references).and_return([reference])
      }
    }

    context 'with :to' do
      let(:args) {
        [
            {
                to: post_instance
            }
        ]
      }

      let(:post_class) {
        FactoryGirl.create(:full_metasploit_cache_post_class)
      }

      let(:post_instance) {
        post_class.build_post_instance
      }

      let(:metasploit_class) {
        double(
            'post Metasploit Module class',
            persister_by_source: {}
        )
      }

      it 'does not access default #persistent' do
        expect(module_ancestor_persister).not_to receive(:persistent)

        persist
      end

      it 'uses :to' do
        expect(post_instance).to receive(:batched_save).and_call_original

        persist
      end

      context 'batched save' do
        context 'failure' do
          before(:each) do
            post_instance.valid?

            expect(post_instance).to receive(:batched_save).and_return(false)
          end

          it 'tags log with Metasploit::Cache::Module::Ancestor#real_path' do
            persist

            expect(logger_string_io.string).to include("[#{post_instance.post_class.ancestor.real_pathname.to_s}]")
          end

          it 'logs validation errors' do
            persist

            full_error_messages = post_instance.errors.full_messages.to_sentence

            expect(full_error_messages).not_to be_blank
            expect(logger_string_io.string).to include("Could not be persisted to #{post_instance.class}: #{full_error_messages}")
          end
        end

        context 'success' do
          specify {
            expect {
              persist
            }.to change(Metasploit::Cache::Post::Instance, :count).by(1)
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
            'post Metasploit Module class',
            persister_by_source: {},
            real_path_sha1_hex_digest: existing_post_instance.post_class.ancestor.real_path_sha1_hex_digest
        )
      }

      #
      # let!s
      #

      let!(:existing_post_instance) {
        FactoryGirl.create(:full_metasploit_cache_post_instance)
      }

      #
      # Callbacks
      #

      before(:each) do
        metasploit_class.persister_by_source[:ancestor] = metasploit_class
      end

      it 'defaults to #persistent' do
        expect(module_ancestor_persister).to receive(:persistent).and_call_original

        persist
      end

      it 'uses #batched_save' do
        expect(module_ancestor_persister.persistent).to receive(:batched_save).and_call_original

        persist
      end
    end
  end
end