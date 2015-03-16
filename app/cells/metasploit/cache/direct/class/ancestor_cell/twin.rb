require 'cell/twin'

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