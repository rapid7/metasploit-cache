# Cell for rendering {Metasploit::Cache::Payload::Stager::Instance#payload_stager_class}
# {Metasploit::Cache::Direct::Class#ancestor} {Metasploit::Cache::Module::Ancestor#contents}.
#
# In addition to content from {Metasploit::Cache::Module::AncestorCell} and
# {Metasploit::Cache::Direct::Class::AncestorCell}, it also includes `#arch` for
# {Metasploit::Cache::Payload::Stager::Instance#architecturable_architectures},, `#authors` for
# {Metasploit::Cache::Payload::Stager::Instance#contributions}, `#description` for
# {Metasploit::Cache::Payload::Stager::Instance#description}, `#handler_klass` for
# {Metasploit::Cache::Payload::Stager::Instance#handler}, `#license` for
# {Metasploit::Cache::Payload::Stager::Instance#licensable_licenses} {Metasploit::Cache::Licensable::Licenses#license}s,
# `#name` for {Metasploit::Cache::Payload::Stager::Instance#name}, `#platform` for
# {Metasploit::Cache::Payload::Stager::Instance#platformable_platforms}
# {Metasploit::Cache::Platformable::Platform#platform}s, and `#privileged` for
# {Metasploit::Cache::Payload::Stager::Instance#privileged}.
class Metasploit::Cache::Payload::Stager::Instance::PayloadStagerClass::AncestorCell < Cell::ViewModel
  include Metasploit::Cache::AncestorCell

  #
  # Properties
  #

  property :architecturable_architectures
  property :payload_stager_class
  property :contributions
  property :description
  property :handler
  property :licensable_licenses
  property :name
  property :platformable_platforms
  property :privileged

  #
  # Instance Methods
  #

  def show(metasploit_module_relative_name:)
    render locals: {
               metasploit_module_relative_name: metasploit_module_relative_name
           }
  end
end
