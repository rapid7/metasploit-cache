RSpec.describe Metasploit::Cache::Module::Namespace::Cache do
  subject(:module_namespace_cache) {
    described_class.new
  }

  context 'validations' do
    it { is_expected.to validate_inclusion_of(:module_type).in_array(Metasploit::Cache::Module::Type::ALL) }

    context 'of #real_path_sha1_hex_digest' do
      it { is_expected.to allow_value(Digest::SHA1.hexdigest('')).for(:real_path_sha1_hex_digest) }
    end
  end

  context '#payload?' do
    subject(:payload?) {
      module_namespace_cache.payload?
    }

    let(:module_namespace_cache) {
      described_class.new(
                         module_type: module_type
      )
    }

    context '#module_type' do
      context 'with nil' do
        let(:module_type) {
          nil
        }

        it { is_expected.to eq(false) }
      end

      context 'with auxiliary' do
        let(:module_type) {
          'auxiliary'
        }

        it { is_expected.to eq(false) }
      end

      context 'with encoder' do
        let(:module_type) {
          'encoder'
        }

        it { is_expected.to eq(false) }
      end

      context 'with exploit' do
        let(:module_type) {
          'exploit'
        }

        it { is_expected.to eq(false) }
      end

      context 'with nop' do
        let(:module_type) {
          'nop'
        }

        it { is_expected.to eq(false) }
      end

      context 'wtih payload' do
        let(:module_type) {
          'payload'
        }

        it { is_expected.to eq(true) }
      end

      context 'with post' do
        let(:module_type) {
          'post'
        }

        it { is_expected.to eq(false) }
      end
    end
  end
end