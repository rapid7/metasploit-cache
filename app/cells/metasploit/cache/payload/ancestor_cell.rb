require 'cell/twin'

# Cell for rendering {Metasploit::Cache::Payload::Ancestor} {Metasploit::Cache::Module::Ancestor#contents}.
class Metasploit::Cache::Payload::AncestorCell < Cell::ViewModel
  #
  # Properties
  #

  property :relative_path

  #
  # Instance Methods
  #

  def show(metasploit_module_relative_name:)
    render locals: {
               metasploit_module_relative_name: metasploit_module_relative_name
           }
  end
end
