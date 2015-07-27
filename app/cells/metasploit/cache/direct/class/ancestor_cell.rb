require 'cell/twin'

# Cell for rendering {Metasploit::Cache::Direct::Class#ancestor} {Metasploit::Cache::Module::Ancestor#contents}.
#
# In addition to content from {Metasploit::Cache::Module::AncestorCell}, it also includes the `Rank` constant using
# the {Metasploit::Cache::Direct::Class#rank} {Metasploit::Cache::Module::Rank#number}.
class Metasploit::Cache::Direct::Class::AncestorCell < Cell::ViewModel
  #
  # Properties
  #

  property :ancestor
  property :rank

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
