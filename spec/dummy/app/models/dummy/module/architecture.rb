class Dummy::Module::Architecture < Metasploit::Model::Base
  include Metasploit::Cache::Module::Architecture

  #
  # Attributes
  #

  # @!attribute [rw] architecture
  #   The architecture supported by the {#module_instance}.
  #
  #   @return [Metasploit::Cache::Architecture]
  attr_accessor :architecture

  # @!attribute [rw] module_instance
  #   The module instance that supports {#architecture}.
  #
  #   @return [Metasploit::Cache::Module::Instance]
  attr_accessor :module_instance
end