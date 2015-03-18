require 'cell/twin'

# Fields used in {Metasploit::Cache::Payload::AncestorCell} template.
class Metasploit::Cache::Payload::AncestorCell::Twin < Cell::Twin
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
