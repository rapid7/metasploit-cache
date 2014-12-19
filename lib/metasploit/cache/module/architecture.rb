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
  # Attributes
  #

  # @!attribute [rw] architecture
  #   The architecture supported by the {#module_instance}.
  #
  #   @return [Metasploit::Cache::Architecture]

  # @!attribute [rw] module_instance
  #   The module instance that supports {#architecture}.
  #
  #   @return [Metasploit::Cache::Module::Instance]
end
