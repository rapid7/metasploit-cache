# Joins {Metasploit::Cache::Module::Instance} and {Metasploit::Cache::Reference}.
module Metasploit::Cache::Module::Reference
  extend ActiveModel::Naming
  extend ActiveSupport::Concern

  include Metasploit::Model::Translation

  included do
    include ActiveModel::Validations

    #
    # Validations
    #

    validates :module_instance, :presence => true
    validates :reference, :presence => true
  end

  #
  # Associations
  #

  # @!attribute [rw] module_instance
  #   {Metasploit::Cache::Module::Instance Module} with {#reference}.
  #
  #   @return [Metasploit::Cache::Module::Instance]

  # @!attribute [rw] reference
  #   {Metasploit::Cache::Reference reference} to exploit or proof-of-concept (PoC) code for {#module_instance}.
  #
  #   @return [Metasploit::Cache::Reference]
end
