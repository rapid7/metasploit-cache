RSpec.shared_examples_for 'Metasploit::Cache::Payload::Ancestor.restrict' do |payload_type:, payload_type_directory:|
  error = "is not #{payload_type}"

  context 'validations' do
    context '#payload_type_matches' do
      subject(:payload_type_errors) {
        subclass_instance.valid?

        subclass_instance.errors[:payload_type]
      }

      let(:subclass_instance) {
        described_class.new(
                           relative_path: relative_path
        )
      }

      context "with '#{payload_type}'" do
        let(:relative_path) {
          "payloads/#{payload_type_directory}/reference/name.rb"
        }

        it { is_expected.not_to include(error) }
      end

      context "without '#{payload_type}'" do
        let(:relative_path) {
          "payloads/not_a_payload_type_directory/reference/name.rb"
        }

        it { is_expected.to include(error) }
      end
    end
  end
end