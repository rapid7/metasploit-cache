RSpec.describe Metasploit::Cache::Direct::Class::Spec::Template do
  subject(:direct_class_spec_template) {
    described_class.new
  }

  context 'validations' do
    context '#ancestor_template_valid' do
      subject(:ancestor_template_errors) {
        direct_class_spec_template.valid?

        direct_class_spec_template.errors[:ancestor_template]
      }

      context 'with #ancestor_template' do
        #
        # lets
        #

        let(:error) {
          I18n.translate!('errors.messages.invalid')
        }

        #
        # Callbacks
        #

        before(:each) do
          expect(direct_class_spec_template.ancestor_template).to receive(:valid?).and_return(valid)
        end

        context 'invalid' do
          let(:valid) {
            false
          }

          it { is_expected.to include(error) }
        end

        context 'valid' do
          let(:valid) {
            true
          }

          it { is_expected.not_to include(error) }
        end
      end
    end
  end
end