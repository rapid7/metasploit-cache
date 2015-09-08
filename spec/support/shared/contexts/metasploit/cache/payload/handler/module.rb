shared_context ':metasploit_cache_payload_handler_module' do
  include_context '$LOAD_PATH'

  #
  # lets
  #

  let(:metasploit_cache_payload_handler_module_load_pathname) {
    Metasploit::Model::Spec.temporary_pathname.join('lib')
  }

  #
  # Callbacks
  #

  before(:each) do
    metasploit_cache_payload_handler_module_load_pathname.mkpath

    $LOAD_PATH.unshift metasploit_cache_payload_handler_module_load_pathname
  end
end
