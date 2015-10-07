RSpec.describe Metasploit::Cache::Payload::Unhandled::Class::Ephemeral do
  include_context 'ActiveSupport::TaggedLogging'

  subject(:payload_unhandled_class_ephemeral) {
    described_class.new(
        payload_unhandled_class_class: expected_payload_unhandled_class.class,
        logger: logger,
        metasploit_class: metasploit_class
    )
  }

  let(:expected_payload_unhandled_class) {
    FactoryGirl.build(
        :metasploit_cache_payload_single_unhandled_class,
        rank: expected_module_rank
    ).tap { |payload_unhandled_class|
      # Set to nil after build so that record passed to #persist_payload_unhandled_class must fill in the rank, but the built
      # template still contains a Rank like a real loading scenario.
      payload_unhandled_class.rank = nil
    }
  }

  let(:expected_module_rank) {
    FactoryGirl.generate :metasploit_cache_module_rank
  }

  let(:metasploit_class) {
    Class.new.tap { |metasploit_class|
      metasploit_class.extend Metasploit::Cache::Cacheable

      rank_number = expected_module_rank.number

      metasploit_class.define_singleton_method(:rank) do
        rank_number
      end
    }
  }

  let(:module_ancestor) {
    expected_payload_unhandled_class.ancestor
  }

  let(:module_ancestor_ephemeral) {
    Metasploit::Cache::Module::Ancestor::Ephemeral.new(
        metasploit_module: metasploit_class,
        real_path_sha1_hex_digest: real_path_sha1_hex_digest
    )
  }

  let(:real_path_sha1_hex_digest) {
    module_ancestor.real_path_sha1_hex_digest
  }

  #
  # Callbacks
  #

  before(:each) do
    metasploit_class.ephemeral_cache_by_source[:ancestor] = module_ancestor_ephemeral
  end

  context 'resurrecting attributes' do
    context '#payload_unhandled_class' do
      subject(:payload_unhandled_class) {
        payload_unhandled_class_ephemeral.payload_unhandled_class
      }

      before(:each) do
        expected_payload_unhandled_class.rank = expected_module_rank
        expected_payload_unhandled_class.save!

        # have to stub because real_path_sha1_hex_digest is normally delegated to the namespace parent
        allow(module_ancestor_ephemeral).to receive(:real_path_sha1_hex_digest).and_return(module_ancestor.real_path_sha1_hex_digest)
      end

      it 'is an instance of a subclass of Metasploit::Cache::Payload::Unhandled::Class' do
        expect(payload_unhandled_class.class).to be < Metasploit::Cache::Payload::Unhandled::Class
      end

      it 'is a Metasploit::Cache::Direct::Class with #ancestor matching pre-existing Metasploit::Cache::Module::Ancestor' do
        expect(payload_unhandled_class).to eq(expected_payload_unhandled_class)
        expect(payload_unhandled_class.ancestor).to eq(module_ancestor)
      end
    end
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:payload_unhandled_class_class) }
    it { is_expected.to validate_presence_of(:logger) }
    it { is_expected.to validate_presence_of(:metasploit_class) }
  end

  context '#persist' do
    subject(:persist) do
      payload_unhandled_class_ephemeral.persist(*args)
    end

    context 'with :to' do
      let(:args) {
        [
            {
                to: expected_payload_unhandled_class
            }
        ]
      }

      it 'does not access default #payload_unhandled_class' do
        expect(payload_unhandled_class_ephemeral).not_to receive(:payload_unhandled_class)

        persist
      end

      it 'uses :to' do
        expect(expected_payload_unhandled_class).to receive(:batched_save).and_call_original

        persist
      end

      context 'with #rank' do
        context 'batched save' do
          context 'failure' do
            include_context 'ActiveSupport::TaggedLogging'

            #
            # Callbacks
            #

            before(:each) do
              expected_payload_unhandled_class.valid?

              expect(expected_payload_unhandled_class).to receive(:batched_save).and_return(false)
            end

            it 'tags log with Metasploit::Cache::Module::Ancestor#real_path' do
              persist

              expect(logger_string_io.string).to include("[#{module_ancestor.real_pathname.to_s}]")
            end

            it 'logs validation errors' do
              persist

              full_error_messages = expected_payload_unhandled_class.errors.full_messages.to_sentence

              expect(full_error_messages).not_to be_blank
              expect(logger_string_io.string).to include("Could not be persisted to #{expected_payload_unhandled_class.class}: #{full_error_messages}")
            end
          end

          context 'success' do
            specify {
              expect {
                persist
              }.to change(Metasploit::Cache::Payload::Unhandled::Class, :count).by(1)
            }
          end
        end
      end

      context 'without #rank' do
        it 'does attempt to save' do
          expect(Metasploit::Cache::Module::Class::Ephemeral::Rank).to receive(:synchronize).and_return(
                                                                           expected_payload_unhandled_class
                                                                       )
          expect(expected_payload_unhandled_class).to receive(:batched_save)

          persist
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

      #
      # Callbacks
      #

      before(:each) do
        expected_payload_unhandled_class.rank = expected_module_rank
        expected_payload_unhandled_class.save!
      end

      it 'defaults to #payload_unhandled_class' do
        expect(payload_unhandled_class_ephemeral).to receive(:payload_unhandled_class).and_call_original

        persist
      end

      context 'with #rank' do
        it 'uses #batched_save' do
          expect(payload_unhandled_class_ephemeral.payload_unhandled_class).to receive(:batched_save).and_call_original

          persist
        end
      end

      context 'without #rank' do
        it 'does attempt to save' do
          expect(Metasploit::Cache::Module::Class::Ephemeral::Rank).to(
              receive(:synchronize).and_return(
                  payload_unhandled_class_ephemeral.payload_unhandled_class
              )
          )
          expect(payload_unhandled_class_ephemeral.payload_unhandled_class).to receive(:batched_save)

          persist
        end
      end
    end
  end
end