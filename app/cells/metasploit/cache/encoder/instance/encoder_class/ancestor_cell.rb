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
  extend ActiveSupport::Autoload

  include Cell::Twin::Properties

  autoload :Twin

  #
  # Properties
  #

  properties Twin

  #
  # Instance Methods
  #

  def show
    render
  end
end
