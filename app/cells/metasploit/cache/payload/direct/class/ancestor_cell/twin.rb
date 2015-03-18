require 'cell/twin'

# Fields used in {Metasploit::Cache::Payload::Direct::Class::AncestorCell} template.
class Metasploit::Cache::Payload::Direct::Class::AncestorCell::Twin < Cell::Twin
  #
  # Options
  #

  option :metasploit_module_relative_name

  #
  # Properties
  #

  property :ancestor
  property :rank
end