require 'cell/twin'

# Fields used in {Metasploit::Cache::Encoder::Instance::EncoderClass::AncestorCell} template.
class Metasploit::Cache::Encoder::Instance::EncoderClass::AncestorCell::Twin < Cell::Twin
  #
  # Options
  #

  option :metasploit_class_relative_name
  option :superclass

  #
  # Properties
  #

  property :architecturable_architectures
  property :encoder_class
  property :contributions
  property :description
  property :licensable_licenses
  property :name
  property :platformable_platforms
end