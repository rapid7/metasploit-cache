RSpec.describe Metasploit::Cache::Module::AncestorCell, type: :cell do
  subject(:module_ancestor_cell) {
    described_class.(module_ancestor)
  }

  let(:metasploit_module_relative_name) {
    FactoryGirl.generate :metasploit_cache_module_ancestor_metasploit_module_relative_name
  }

  let(:module_ancestor) {
    FactoryGirl.create(module_ancestor_factory)
  }

  context 'cell rendering' do
    context 'rendering template' do
      subject(:template) {
        module_ancestor_cell.(
            :show,
            metasploit_module_relative_name: metasploit_module_relative_name,
            superclass: 'Metasploit::Model::Base'
        )
      }

      context 'Metasploit::Cache::Module::Ancestor#module_type' do
        context 'with auxiliary' do
          let(:module_ancestor_factory) {
            :metasploit_cache_auxiliary_ancestor
          }

          it {
            is_expected.to eq(
                               <<-EOS.strip_heredoc.strip
                               # Module Type: auxiliary
                               # Reference Name: #{module_ancestor.reference_name}
                               class #{metasploit_module_relative_name} < Metasploit::Model::Base
                               end
                               EOS
                             )
          }
        end

        context 'with encoder' do
          let(:module_ancestor_factory) {
            :metasploit_cache_encoder_ancestor
          }

          it {
            is_expected.to eq(
                               <<-EOS.strip_heredoc.strip
                               # Module Type: encoder
                               # Reference Name: #{module_ancestor.reference_name}
                               class #{metasploit_module_relative_name} < Metasploit::Model::Base
                               end
                               EOS
                           )
          }
        end

        context 'with exploit' do
          let(:module_ancestor_factory) {
            :metasploit_cache_exploit_ancestor
          }

          it {
            is_expected.to eq(
                               <<-EOS.strip_heredoc.strip
                               # Module Type: exploit
                               # Reference Name: #{module_ancestor.reference_name}
                               class #{metasploit_module_relative_name} < Metasploit::Model::Base
                               end
                           EOS
                           )
          }
        end

        context 'with nop' do
          let(:module_ancestor_factory) {
            :metasploit_cache_nop_ancestor
          }

          it {
            is_expected.to eq(
                               <<-EOS.strip_heredoc.strip
                               # Module Type: nop
                               # Reference Name: #{module_ancestor.reference_name}
                               class #{metasploit_module_relative_name} < Metasploit::Model::Base
                               end
                           EOS
                           )
          }
        end

        context 'with post' do
          let(:module_ancestor_factory) {
            :metasploit_cache_post_ancestor
          }

          it {
            is_expected.to eq(
                               <<-EOS.strip_heredoc.strip
                               # Module Type: post
                               # Reference Name: #{module_ancestor.reference_name}
                               class #{metasploit_module_relative_name} < Metasploit::Model::Base
                               end
                           EOS
                           )
          }
        end
      end
    end
  end
end
