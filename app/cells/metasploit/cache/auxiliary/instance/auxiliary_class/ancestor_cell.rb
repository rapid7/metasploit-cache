require 'cell/twin'

# Cell for rendering {Metasploit::Cache::Auxiliary::Instance#auxiliary_class}
# {Metasploit::Cache::Direct::Class#ancestor} {Metasploit::Cache::Module::Ancestor#contents}.
#
# In addition to content from {Metasploit::Cache::Module::AncestorCell} and
# {Metasploit::Cache::Direct::Class::AncestorCell}, it also includes `#actions` for
# {Metasploit::Cache::Auxiliary::Instance#actions}, `#authors` for
# {Metasploit::Cache::Auxiliary::Instance#contributions}, `#default_action` for
# {Metasploit::Cache::Auxiliary::Instance#default_action}, `#description` for
# {Metasploit::Cache::Auxiliary::Instance#description}, `#license` for
# {Metasploit::Cache::Auxiliary::Instance#licensable_licenses} {Metasploit::Cache::Licensable::Licenses#license}s,
# `#name` for {Metasploit::Cache::Auxiliary::Instance#name}, and `#stance` for
# {Metasploit::Cache::Auxiliary::Instance#stance}.
class Metasploit::Cache::Auxiliary::Instance::AuxiliaryClass::AncestorCell < Cell::ViewModel
  include Metasploit::Cache::AncestorCell

  #
  # Properties
  #

  property :actions
  property :auxiliary_class
  property :contributions
  property :default_action
  property :description
  property :licensable_licenses
  property :name
  property :stance

  #
  # Instance Methods
  #

  def show(metasploit_class_relative_name:, superclass:)
    render locals: {
               metasploit_class_relative_name: metasploit_class_relative_name,
               superclass: superclass
           }
  end
end
