require 'cell/twin'

# Cell for rendering {Metasploit::Cache::Payload::Direct::Class#ancestor}
# {Metasploit::Cache::Module::Ancestor#contents}.
#
# In addition to content from {Metasploit::Cache::Payload::AncestorCell}, it also includes the `Rank` constant using
# the {Metasploit::Cache::Direct::Class#rank} {Metasploit::Cache::Module::Rank#number}.
class Metasploit::Cache::Payload::Direct::Class::AncestorCell < Cell::ViewModel
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
