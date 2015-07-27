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

        context 'with single' do
          let(:payload_ancestor) {
            FactoryGirl.build(:metasploit_cache_payload_single_ancestor)
          }

          it {
            is_expected.to eq(
                               <<-EOS.strip_heredoc.strip
                               # Module Type: payload
                               # Payload Type: single
                               # Reference Name: #{payload_ancestor.reference_name}
                               module #{metasploit_module_relative_name}
                               end
                               EOS
                             )
          }
        end

        context 'with stage' do
          let(:payload_ancestor) {
            FactoryGirl.build(:metasploit_cache_payload_stage_ancestor)
          }

          it {
            is_expected.to eq(
                               <<-EOS.strip_heredoc.strip
                               # Module Type: payload
                               # Payload Type: stage
                               # Reference Name: #{payload_ancestor.reference_name}
                               module #{metasploit_module_relative_name}
                               end
                               EOS
                             )
          }
        end

        context 'with stager' do
          let(:payload_ancestor) {
            FactoryGirl.build(:metasploit_cache_payload_stager_ancestor)
          }

          it {
            is_expected.to eq(
                               <<-EOS.strip_heredoc.strip
                               # Module Type: payload
                               # Payload Type: stager
                               # Reference Name: #{payload_ancestor.reference_name}
                               module #{metasploit_module_relative_name}
                               end
                               EOS
                             )
          }
        end
      end
    end
  end
end
