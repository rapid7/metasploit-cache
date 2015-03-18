require 'cell/twin'

# Fields used in {Metasploit::Cache::Direct::Class::AncestorCell} template.
class Metasploit::Cache::Direct::Class::AncestorCell::Twin < Cell::Twin
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