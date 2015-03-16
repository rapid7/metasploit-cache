require 'cell/twin'

# Cell for rendering {Metasploit::Cache::Module::Ancestor#contents}.
class Metasploit::Cache::Module::AncestorCell < Cell::ViewModel
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
