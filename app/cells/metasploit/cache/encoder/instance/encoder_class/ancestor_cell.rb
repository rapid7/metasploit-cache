require 'cell/twin'

# Cell for rendering {Metasploit::Cache::Encoder::Instance#encoder_class}
# {Metasploit::Cache::Direct::Class#ancestor} {Metasploit::Cache::Module::Ancestor#contents}.
#
# In addition to content from {Metasploit::Cache::Module::AncestorCell} and
# {Metasploit::Cache::Direct::Class::AncestorCell}, it also includes `#arch` for
# {Metasploit::Cache::Encoder#architecturable_architectures}, `#authors` for
# {Metasploit::Cache::Encoder::Instance#contributions}, `#default_action` for
# {Metasploit::Cache::Encoder::Instance#default_action}, `#description` for
# {Metasploit::Cache::Encoder::Instance#description}, `#license` for
# {Metasploit::Cache::Encoder::Instance#licensable_licenses} {Metasploit::Cache::Licensable::Licenses#license}s,
# `#name` for {Metasploit::Cache::Encoder::Instance#name}, and `#platform` for
# {Metasploit::Cache::Encoder#platformable_platforms}.
class Metasploit::Cache::Encoder::Instance::EncoderClass::AncestorCell < Cell::ViewModel
  include Metasploit::Cache::AncestorCell

  #
  # Properties
  #

  property :architecturable_architectures
  property :encoder_class
  property :contributions
  property :description
  property :licensable_licenses
  property :name
  property :platformable_platforms

  #
  # Instance Methods
  #

  def show(metasploit_class_relative_name:, superclass:)
    render locals: {
               metasploit_class_relative_name: metasploit_class_relative_name,
               superclass: superclass
           }
  end
end
