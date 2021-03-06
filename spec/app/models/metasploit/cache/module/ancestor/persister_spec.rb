RSpec.describe Metasploit::Cache::Module::Ancestor::Persister, type: :model do
  include_context 'ActiveSupport::TaggedLogging'

  subject(:module_ancestor_persister) {
    described_class.new(
        ephemeral: metasploit_module,
        logger: logger,
        real_path_sha1_hex_digest: real_path_sha1_hex_digest
    )
  }

  let(:metasploit_module) {
    Module.new
  }

  let(:real_path_sha1_hex_digest) {
    expected_module_ancestor.real_path_sha1_hex_digest
  }

  let(:expected_module_ancestor) do
    FactoryGirl.create(:metasploit_cache_auxiliary_ancestor)
  end

  context 'resurrecting attributes' do
    context '#persistent' do
      subject(:persistent) {
        module_ancestor_persister.persistent
      }

      before(:each) do
        # have to stub because real_path_sha1_hex_digest is normally delegated to the namespace parent
        allow(module_ancestor_persister).to receive(:real_path_sha1_hex_digest).and_return(expected_module_ancestor.real_path_sha1_hex_digest)
      end

      it 'is a Metasploit::Cache::Module::Ancestor with matching #real_path_sha1_hex_digest' do
        expect(persistent).to eq(expected_module_ancestor)
      end
    end
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:ephemeral) }
    it { is_expected.to validate_presence_of(:logger) }
    it { is_expected.to validate_presence_of(:real_path_sha1_hex_digest) }
  end

  context '#persist' do
    subject(:persist) {
      module_ancestor_persister.persist(*args)
    }

    context 'with :to' do
      let(:args) {
        [
            {
                to: module_ancestor
            }
        ]
      }

      let(:module_ancestor) {
        FactoryGirl.build(:metasploit_cache_auxiliary_ancestor)
      }

      it 'does not access default #persistent' do
        expect(module_ancestor_persister).not_to receive(:persistent)

        persist
      end

      it 'uses :to' do
        expect(module_ancestor).to receive(:batched_save).and_call_original

        persist
      end

      context 'batched save' do
        before(:each) do
          expect(module_ancestor).to receive(:batched_save).and_return(success)
        end

        context 'failure' do
          include_context 'ActiveSupport::TaggedLogging'

          #
          # lets
          #

          let(:module_ancestor) {
            super().tap { |module_ancestor|
              module_ancestor.relative_path = File.join('does', 'not', 'exist.rb')
            }
          }

          let(:success) {
            false
          }

          #
          # Callbacks
          #

          before(:each) do
            module_ancestor.valid?
            module_ancestor_persister.logger = logger
          end

          it 'tags log with Metasploit::Cache::Module::Ancestor#real_path' do
            persist

            expect(logger_string_io.string).to include("[#{module_ancestor.real_pathname.to_s}]")
          end

          it 'logs validation errors' do
            persist

            full_error_messages = module_ancestor.errors.full_messages.to_sentence

            expect(full_error_messages).not_to be_blank
            expect(logger_string_io.string).to include("Could not be persisted to Metasploit::Cache::Auxiliary::Ancestor: #{full_error_messages}")
          end
        end

        context 'success' do
          let(:success) {
            true
          }

          specify {
            expect {
              persist
            }.to change(Metasploit::Cache::Module::Ancestor, :count).by(1)
          }
        end
      end
    end

    context 'without :to' do
      let(:args) {
        []
      }

      it 'defaults to #persistent' do
        expect(module_ancestor_persister).to receive(:persistent).and_call_original

        persist
      end

      it 'uses #persistent' do
        expect(module_ancestor_persister.persistent).to receive(:batched_save).and_call_original

        persist
      end
    end
  end
end