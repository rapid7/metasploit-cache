RSpec.describe Metasploit::Cache::Direct::Class::AncestorCell, type: :cell do
  subject(:direct_class_ancestor_cell) {
    cell(
        'metasploit/cache/direct/class/ancestor',
        direct_class,
        metasploit_module_relative_name: metasploit_module_relative_name,
        superclass: 'Metasploit::Model::Base'
    )
  }

  let(:direct_class) {
    FactoryGirl.create(direct_class_factory)
  }

  let(:metasploit_module_relative_name) {
    FactoryGirl.generate :metasploit_cache_module_ancestor_metasploit_module_relative_name
  }

  context 'cell rendering' do
    context 'rendering template' do
      subject(:template) {
        direct_class_ancestor_cell.call
      }

      context 'Metasploit::Cache::Module::Ancestor#module_type' do
        context 'with auxiliary' do
          let(:direct_class_factory) {
            :metasploit_cache_auxiliary_class
          }

          it {
            is_expected.to eq(
                               <<-EOS.strip_heredoc.strip
                               # Module Type: auxiliary
                               # Reference Name: #{direct_class.ancestor.reference_name}
                               class #{metasploit_module_relative_name} < Metasploit::Model::Base
                                 #
                                 # CONSTANTS
                                 #

                                 Rank = #{direct_class.rank.number}
                               end
                               EOS
                             )
          }
        end

        context 'with encoder', pending: 'Metasploit::Cache::Encoder::Classn not available on branch' do
          let(:direct_class_factory) {
            :metasploit_cache_encoder_class
          }

          it {
            is_expected.to eq(
                               <<-EOS.strip_heredoc.strip
                               # Module Type: encoder
                               # Reference Name: #{direct_class.ancestor.reference_name}
                               class #{metasploit_module_relative_name} < Metasploit::Model::Base
                                 #
                                 # CONSTANTS
                                 #

                                 Rank = #{direct_class.rank.number}
                               end
                               EOS
                           )
          }
        end

        context 'with exploit', pending: 'Metasploit::Cache::Exploit::Classn not available on branch' do
          let(:direct_class_factory) {
            :metasploit_cache_exploit_class
          }

          it {
            is_expected.to eq(
                               <<-EOS.strip_heredoc.strip
                               # Module Type: exploit
                               # Reference Name: #{direct_class.ancestor.reference_name}
                               class #{metasploit_module_relative_name} < Metasploit::Model::Base
                                 #
                                 # CONSTANTS
                                 #

                                 Rank = #{direct_class.rank.number}
                               end
                           EOS
                           )
          }
        end

        context 'with nop', pending: 'Metasploit::Cache::Nop::Class not available on branch' do
          let(:direct_class_factory) {
            :metasploit_cache_nop_class
          }

          it {
            is_expected.to eq(
                               <<-EOS.strip_heredoc.strip
                               # Module Type: nop
                               # Reference Name: #{direct_class.ancestor.reference_name}
                               class #{metasploit_module_relative_name} < Metasploit::Model::Base
                                 #
                                 # CONSTANTS
                                 #

                                 Rank = #{direct_class.rank.number}
                               end
                           EOS
                           )
          }
        end

        context 'with post', pending: 'Metasploit::Cache::Post::Class not available on branch' do
          let(:direct_class_factory) {
            :metasploit_cache_post_class
          }

          it {
            is_expected.to eq(
                               <<-EOS.strip_heredoc.strip
                               # Module Type: post
                               # Reference Name: #{direct_class.ancestor.reference_name}
                               class #{metasploit_module_relative_name} < Metasploit::Model::Base
                                 #
                                 # CONSTANTS
                                 #

                                 Rank = #{direct_class.rank.number}
                               end
                           EOS
                           )
          }
        end
      end
    end
  end
end
