require 'cell/twin'

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
