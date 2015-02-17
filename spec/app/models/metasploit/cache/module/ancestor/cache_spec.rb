RSpec.describe Metasploit::Cache::Module::Ancestor::Cache do
  subject(:module_ancestor_cache) {
    described_class.new(
        metasploit_module: metasploit_module,
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
    FactoryGirl.create(:metasploit_cache_module_ancestor)
  end

  context 'resurrecting attributes' do
    context '#module_ancestor' do
      subject(:module_ancestor) {
        module_ancestor_cache.module_ancestor
      }


      before(:each) do
        # have to stub because real_path_sha1_hex_digest is normally delegated to the namespace parent
        allow(module_ancestor_cache).to receive(:real_path_sha1_hex_digest).and_return(expected_module_ancestor.real_path_sha1_hex_digest)
      end

      it 'is a Metasploit::Cache::Module::Ancestor with matching #real_path_sha1_hex_digest' do
        expect(module_ancestor).to eq(expected_module_ancestor)
      end
    end
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:metasploit_module) }
  end

  context '#persist' do
    subject(:persist) {
      module_ancestor_cache.persist(*args)
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
        FactoryGirl.build(:metasploit_cache_module_ancestor)
      }

      it 'does not access default #module_ancestor' do
        expect(module_ancestor_cache).not_to receive(:module_ancestor)

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
          #
          # lets
          #

          let(:logger) {
            ActiveSupport::TaggedLogging.new(
                Logger.new(string_io)
            )
          }

          let(:string_io) {
            StringIO.new
          }

          let(:success) {
            false
          }

          #
          # Callbacks
          #

          before(:each) do
            module_ancestor_cache.logger = logger
          end

          it 'tags log with Metasploit::Cache::Module::Ancestor#real_path' do
            persist

            expect(string_io.string).to include("[#{module_ancestor.real_path}]")
          end

          it 'logs validation errors' do
            persist

            full_error_messages = module_ancestor.errors.full_messages.to_sentence

            expect(full_error_messages).not_to be_blank
            expect(string_io.string).to include("Could not be persisted: #{full_error_messages}")
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

      it 'defaults to #module_ancestor' do
        expect(module_ancestor_cache).to receive(:module_ancestor).and_call_original

        persist
      end

      it 'uses #module_ancestor' do
        expect(module_ancestor_cache.module_ancestor).to receive(:batched_save).and_call_original

        persist
      end
    end
  end
end