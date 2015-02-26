RSpec.shared_examples_for 'Metasploit::Cache::Module::Ancestor.restrict' do |module_type:, module_type_directory:|
  error = "is not #{module_type}"

  context 'validations' do
    context '#module_type_matches' do
      subject(:module_type_errors) {
        subclass_instance.valid?

        subclass_instance.errors[:module_type]
      }

      let(:subclass_instance) {
        described_class.new(
                           relative_path: relative_path
        )
      }

      context "with '#{module_type}'" do
        let(:relative_path) {
          "#{module_type_directory}/reference/name.rb"
        }

        it { is_expected.not_to include(error) }
      end

      context "without '#{module_type}'" do
        let(:relative_path) {
          "not_a_module_type_directory/reference/name.rb"
        }

        it { is_expected.to include(error) }
      end
    end
  end
end