require 'cell/twin'

class Metasploit::Cache::Payload::AncestorCell < Cell::ViewModel
  include Cell::Twin::Properties

  class Twin < Cell::Twin
    #
    # Options
    #

    option :metasploit_module_relative_name

    #
    # Properties
    #

    property :module_type
    property :payload_type
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
