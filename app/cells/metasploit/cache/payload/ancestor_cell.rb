require 'cell/twin'

# Cell for rendering {Metasploit::Cache::Payload::Ancestor} {Metasploit::Cache::Module::Ancestor#contents}.
class Metasploit::Cache::Payload::AncestorCell < Cell::ViewModel
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
