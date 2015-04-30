RSpec.describe Metasploit::Cache::Payload::Direct::Class::AncestorCell, type: :cell do
  subject(:payload_direct_class_ancestor_cell) {
    cell(
        'metasploit/cache/payload/direct/class/ancestor',
        payload_direct_class,
        metasploit_module_relative_name: metasploit_module_relative_name
    )
  }

  let(:payload_direct_class) {
    FactoryGirl.create(payload_direct_class_factory)
  }

  let(:metasploit_module_relative_name) {
    FactoryGirl.generate :metasploit_cache_module_ancestor_metasploit_module_relative_name
  }

  context 'cell rendering' do
    context 'rendering template' do
      subject(:template) {
        payload_direct_class_ancestor_cell.call
      }

      context 'Metasploit::Cache::Payload::Ancestor#payload_type' do
        context 'with single' do
          let(:payload_direct_class_factory) {
            :metasploit_cache_payload_single_class
          }

          it {
            is_expected.to eq(
                               <<-EOS.strip_heredoc.strip
                               # Module Type: payload
                               # Payload Type: single
                               # Reference Name: #{payload_direct_class.ancestor.reference_name}
                               module #{metasploit_module_relative_name}
                                 #
                                 # CONSTANTS
                                 #

                                 Rank = #{payload_direct_class.rank.number}
                               end
                               EOS
                           )
          }
        end
      end
    end
  end
end
