RSpec.describe Metasploit::Cache::Direct::Class::Ephemeral, type: :model do
  include_context 'ActiveSupport::TaggedLogging'

  subject(:direct_class_ephemeral) {
    described_class.new(
        logger: logger,
        metasploit_class: metasploit_class,
        persistent_class: expected_direct_class.class
    )
  }

  let(:expected_direct_class) {
    FactoryGirl.build(
        expected_direct_class_factory,
        rank: expected_module_rank
    ).tap { |direct_class|
      # Set to nil after build so that record passed to #persist must fill in the rank, but the built
      # template still contains a Rank like a real loading scenario.
      direct_class.rank = nil
    }
  }

  let(:expected_direct_class_factory) {
    FactoryGirl.generate :metasploit_cache_direct_class_factory
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
    expected_direct_class.ancestor
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
    context '#persistent' do
      subject(:persistent) {
        direct_class_ephemeral.persistent
      }

      before(:each) do
        expected_direct_class.rank = expected_module_rank
        expected_direct_class.save!

        # have to stub because real_path_sha1_hex_digest is normally delegated to the namespace parent
        allow(module_ancestor_ephemeral).to receive(:real_path_sha1_hex_digest).and_return(module_ancestor.real_path_sha1_hex_digest)
      end

      it 'is an instance of a subclass of Metasploit::Cache::Direct::Class' do
        expect(persistent.class).to be < Metasploit::Cache::Direct::Class
      end

      it 'is a Metasploit::Cache::Direct::Class with #ancestor matching pre-existing Metasploit::Cache::Module::Ancestor' do
        expect(persistent).to eq(expected_direct_class)
        expect(persistent.ancestor).to eq(module_ancestor)
      end
    end
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:logger) }
    it { is_expected.to validate_presence_of(:metasploit_class) }
    it { is_expected.to validate_presence_of(:persistent_class) }
  end

  context '#persist' do
    subject(:persist) do
      direct_class_ephemeral.persist(*args)
    end

    context 'with :to' do
      let(:args) {
        [
            {
                to: expected_direct_class
            }
        ]
      }

      it 'does not access default #persistent' do
        expect(direct_class_ephemeral).not_to receive(:persistent)

        persist
      end

      it 'uses :to' do
        expect(expected_direct_class).to receive(:batched_save).and_call_original

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
              expected_direct_class.valid?

              expect(expected_direct_class).to receive(:batched_save).and_return(false)
            end

            it 'tags log with Metasploit::Cache::Module::Ancestor#real_path' do
              persist

              expect(logger_string_io.string).to include("[#{module_ancestor.real_pathname.to_s}]")
            end

            it 'logs validation errors' do
              persist

              full_error_messages = expected_direct_class.errors.full_messages.to_sentence

              expect(full_error_messages).not_to be_blank
              expect(logger_string_io.string).to include("Could not be persisted to #{expected_direct_class.class}: #{full_error_messages}")
            end
          end

          context 'success' do
            specify {
              expect {
                persist
              }.to change(Metasploit::Cache::Direct::Class, :count).by(1)
            }
          end
        end
      end

      context 'without #rank' do
        it 'does attempt to save' do
          expect(Metasploit::Cache::Module::Class::Ephemeral::Rank).to receive(:synchronize).and_return(expected_direct_class)
          expect(expected_direct_class).to receive(:batched_save)

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
        expected_direct_class.rank = expected_module_rank
        expected_direct_class.save!
      end

      it 'defaults to #persistent' do
        expect(direct_class_ephemeral).to receive(:persistent).and_call_original

        persist
      end

      context 'with #rank' do
        it 'uses #batched_save' do
          expect(direct_class_ephemeral.persistent).to receive(:batched_save).and_call_original

          persist
        end
      end

      context 'without #rank' do
        it 'does attempt to save' do
          expect(Metasploit::Cache::Module::Class::Ephemeral::Rank).to receive(:synchronize).and_return(direct_class_ephemeral.persistent)
          expect(direct_class_ephemeral.persistent).to receive(:batched_save)

          persist
        end
      end
    end
  end
end