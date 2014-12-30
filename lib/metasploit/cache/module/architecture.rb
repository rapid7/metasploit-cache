# Model that joins {Metasploit::Cache::Architecture} and {Metasploit::Cache::Module::Instance}.
module Metasploit::Cache::Module::Architecture
  extend ActiveModel::Naming
  extend ActiveSupport::Concern

  include Metasploit::Model::Translation

  included do
    include ActiveModel::Validations

    #
    # Validations
    #

    validates :architecture,
              :presence => true
    validates :module_instance,
              :presence => true
  end

  #
  # Associations
  #

  # @!attribute architecture
  #   The architecture supported by the {#module_instance}.
  #
  #   @return [Metasploit::Cache::Architecture]

  # @!attribute module_instance
  #   The module instance that supports {#architecture}.
  #
  #   @return [Metasploit::Cache::Module::Instance]

  #
  # Instance Methods
  #

  # @!method architecture=(architecture)
  #   Sets {#architecture}.
  #
  #   @param architecture [Metasploit::Cache::Architecture] the architecture supported by the {#module_instance}.
  #   @return [void]

  # @!method module_instance=(module_instance)
  #   Sets {#module_instance}.
  #
  #   @param module_instance [MEtasploit::Cache::Module::Instance] the module instance that supports {#architecture}.
  #   @return [void]
end
