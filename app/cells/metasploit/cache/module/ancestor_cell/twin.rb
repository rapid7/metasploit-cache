require 'cell/twin'

# Fields used in {Metasploit::Cache::Module::AncestorCell} template.
class Metasploit::Cache::Module::AncestorCell::Twin < Cell::Twin
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
