require 'cell/twin'

# Cell for rendering {Metasploit::Cache::Module::Ancestor#contents}.
class Metasploit::Cache::Module::AncestorCell < Cell::ViewModel
  #
  # Properties
  #

  property :relative_path

  #
  # Instance Methods
  #

  def show(metasploit_module_relative_name:, superclass:)
    render locals: {
               metasploit_module_relative_name: metasploit_module_relative_name,
               superclass: superclass
           }
  end
end
