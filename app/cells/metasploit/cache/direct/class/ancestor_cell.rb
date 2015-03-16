require 'cell/twin'

class Metasploit::Cache::Direct::Class::AncestorCell < Cell::ViewModel
  include Cell::Twin::Properties

  class Twin < Cell::Twin
    #
    # Options
    #

    option :metasploit_module_relative_name
    option :superclass

    #
    # Properties
    #

    property :ancestor
    property :rank
  end

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
