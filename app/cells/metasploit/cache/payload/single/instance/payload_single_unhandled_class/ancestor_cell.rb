# Cell for rendering {Metasploit::Cache::Payload::Single::Instance#payload_single_unhandled_class}
# {Metasploit::Cache::Direct::Class#ancestor} {Metasploit::Cache::Module::Ancestor#contents}.
#
# In addition to content from {Metasploit::Cache::Module::AncestorCell} and
# {Metasploit::Cache::Direct::Class::AncestorCell}, it also includes `#arch` for
# {Metasploit::Cache::Payload::Single::Instance#architecturable_architectures},, `#authors` for
# {Metasploit::Cache::Payload::Single::Instance#contributions}, `#description` for
# {Metasploit::Cache::Payload::Single::Instance#description}, `#handler_klass` for
# {Metasploit::Cache::Payload::Single::Instance#handler}, `#license` for
# {Metasploit::Cache::Payload::Single::Instance#licensable_licenses} {Metasploit::Cache::Licensable::Licenses#license}s,
# `#name` for {Metasploit::Cache::Payload::Single::Instance#name}, `#platform` for
# {Metasploit::Cache::Payload::Single::Instance#platformable_platforms}
# {Metasploit::Cache::Platformable::Platform#platform}s, and `#privileged` for
# {Metasploit::Cache::Payload::Single::Instance#privileged}.
class Metasploit::Cache::Payload::Single::Instance::PayloadSingleUnhandledClass::AncestorCell < Cell::ViewModel
  include Metasploit::Cache::AncestorCell

  #
  # Properties
  #

  property :architecturable_architectures
  property :contributions
  property :description
  property :handler
  property :licensable_licenses
  property :name
  property :payload_single_unhandled_class
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
