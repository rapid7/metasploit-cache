# Cell for rendering {Metasploit::Cache::Payload::Stage::Instance#payload_stage_class}
# {Metasploit::Cache::Direct::Class#ancestor} {Metasploit::Cache::Module::Ancestor#contents}.
#
# In addition to content from {Metasploit::Cache::Module::AncestorCell} and
# {Metasploit::Cache::Direct::Class::AncestorCell}, it also includes `#arch` for
# {Metasploit::Cache::Payload::Stage::Instance#architecturable_architectures},, `#authors` for
# {Metasploit::Cache::Payload::Stage::Instance#contributions}, `#description` for
# {Metasploit::Cache::Payload::Stage::Instance#description}, `#license` for
# {Metasploit::Cache::Payload::Stage::Instance#licensable_licenses} {Metasploit::Cache::Licensable::Licenses#license}s,
# `#name` for {Metasploit::Cache::Payload::Stage::Instance#name}, `#platform` for
# {Metasploit::Cache::Payload::Stage::Instance#platformable_platforms}
# {Metasploit::Cache::Platformable::Platform#platform}s, and `#privileged` for
# {Metasploit::Cache::Payload::Stage::Instance#privileged}.
class Metasploit::Cache::Payload::Stage::Instance::PayloadStageClass::AncestorCell < Cell::ViewModel
  include Metasploit::Cache::AncestorCell

  #
  # Properties
  #

  property :architecturable_architectures
  property :payload_stage_class
  property :contributions
  property :description
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
