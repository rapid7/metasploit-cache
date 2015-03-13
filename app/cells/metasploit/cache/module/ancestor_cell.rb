require 'cell/twin'

class Metasploit::Cache::Module::AncestorCell < Cell::ViewModel
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

    property :module_type
    property :reference_name
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
