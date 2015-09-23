require 'cell/twin'

# Cell for rendering {Metasploit::Cache::Payload::Unhandled::Class#ancestor}
# {Metasploit::Cache::Module::Ancestor#contents}.
#
# In addition to content from {Metasploit::Cache::Payload::AncestorCell}, it also includes the `Rank` constant using
# the {Metasploit::Cache::Direct::Class#rank} {Metasploit::Cache::Module::Rank#number}.
class Metasploit::Cache::Payload::Unhandled::Class::AncestorCell < Cell::ViewModel
  #
  # Properties
  #

  property :ancestor
  property :name
  property :rank

  #
  # Instance Methods
  #

  def show(metasploit_module_relative_name:)
    render locals: {
               metasploit_module_relative_name: metasploit_module_relative_name
           }
  end
end
