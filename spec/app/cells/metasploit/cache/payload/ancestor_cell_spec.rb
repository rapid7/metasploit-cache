RSpec.describe Metasploit::Cache::Payload::AncestorCell, type: :cell do
  subject(:payload_ancestor_cell) {
    described_class.(payload_ancestor)
  }

  let(:metasploit_module_relative_name) {
    FactoryGirl.generate :metasploit_cache_module_ancestor_metasploit_module_relative_name
  }

  context 'cell rendering' do
    context 'rendering template' do
      subject(:template) {
        payload_ancestor_cell.(
            :show,
            metasploit_module_relative_name: metasploit_module_relative_name
        )
      }

      context 'Metasploit::Cache::Payload::Ancestor#payload_type' do
        let(:expected_rendered_template) {
          <<-EOS.strip_heredoc.strip
          # Relative Path: #{payload_ancestor.relative_path}
          module #{metasploit_module_relative_name}
          end
          EOS
        }

        context 'with single' do
          let(:payload_ancestor) {
            FactoryGirl.build(:metasploit_cache_payload_single_ancestor)
          }

          it { is_expected.to eq(expected_rendered_template) }
        end

        context 'with stage' do
          let(:payload_ancestor) {
            FactoryGirl.build(:metasploit_cache_payload_stage_ancestor)
          }

          it { is_expected.to eq(expected_rendered_template) }
        end

        context 'with stager' do
          let(:payload_ancestor) {
            FactoryGirl.build(:metasploit_cache_payload_stager_ancestor)
          }

          it { is_expected.to eq(expected_rendered_template) }
        end
      end
    end
  end
end
