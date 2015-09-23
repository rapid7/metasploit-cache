RSpec.describe Metasploit::Cache::Payload::Unhandled::Class::AncestorCell, type: :cell do
  subject(:payload_unhandled_class_ancestor_cell) {
    described_class.(payload_unhandled_class)
  }

  let(:payload_unhandled_class) {
    FactoryGirl.create(payload_unhandled_class_factory)
  }

  let(:metasploit_module_relative_name) {
    FactoryGirl.generate :metasploit_cache_module_ancestor_metasploit_module_relative_name
  }

  context 'cell rendering' do
    context 'rendering template' do
      subject(:template) {
        payload_unhandled_class_ancestor_cell.(
            :show,
            metasploit_module_relative_name: metasploit_module_relative_name
        )
      }

      context 'Metasploit::Cache::Payload::Ancestor#payload_type' do
        context 'with single' do
          let(:payload_unhandled_class_factory) {
            :metasploit_cache_payload_single_unhandled_class
          }

          it {
            is_expected.to eq(
                               <<-EOS.strip_heredoc.strip
                               # Relative Path: #{payload_unhandled_class.ancestor.relative_path}
                               module #{metasploit_module_relative_name}
                                 #
                                 # CONSTANTS
                                 #

                                 Rank = #{payload_unhandled_class.rank.number}
                               end
                               EOS
                           )
          }
        end

        context 'with stage' do
          let(:payload_unhandled_class_factory) {
            :metasploit_cache_payload_stage_class
          }

          it {
            is_expected.to eq(
                               <<-EOS.strip_heredoc.strip
                               # Relative Path: #{payload_unhandled_class.ancestor.relative_path}
                               module #{metasploit_module_relative_name}
                                 #
                                 # CONSTANTS
                                 #

                                 Rank = #{payload_unhandled_class.rank.number}
                               end
                               EOS
                           )
          }
        end

        context 'with stager' do
          let(:payload_unhandled_class_factory) {
            :metasploit_cache_payload_stager_class
          }

          it {
            is_expected.to eq(
                               <<-EOS.strip_heredoc.strip
                               # Relative Path: #{payload_unhandled_class.ancestor.relative_path}
                               module #{metasploit_module_relative_name}
                                 #
                                 # CONSTANTS
                                 #

                                 Rank = #{payload_unhandled_class.rank.number}
                               end
                               EOS
                           )
          }
        end
      end
    end
  end
end
