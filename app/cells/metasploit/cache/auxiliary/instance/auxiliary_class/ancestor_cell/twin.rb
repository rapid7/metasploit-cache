require 'cell/twin'

# Fields used in {Metasploit::Cache::Auxiliary::Instance::AuxiliaryClass::AncestorCell} template.
class Metasploit::Cache::Auxiliary::Instance::AuxiliaryClass::AncestorCell::Twin < Cell::Twin
  #
  # Options
  #

  option :metasploit_class_relative_name
  option :superclass

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
end