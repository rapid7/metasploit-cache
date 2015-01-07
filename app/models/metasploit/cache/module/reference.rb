# Join model between {Metasploit::Cache::Module::Instance modules} and {Metasploit::Cache::Reference references} that refer to the exploit in the
# modules.
class Metasploit::Cache::Module::Reference < ActiveRecord::Base
  include Metasploit::Model::Translation
  include MetasploitDataModels::Batch::Descendant

  #
  # Associations
  #

  # @!attribute module_instance
  #   {Metasploit::Cache::Module::Instance Module} with {#reference}.
  #
  #   @return [Metasploit::Cache::Module::Instance]
  belongs_to :module_instance, class_name: 'Metasploit::Cache::Module::Instance', inverse_of: :module_references

  # @!attribute reference
  #   {Metasploit::Cache::Reference reference} to exploit or proof-of-concept (PoC) code for {#module_instance}.
  #
  #   @return [Metasploit::Cache::Reference]
  belongs_to :reference, class_name: 'Metasploit::Cache::Reference', inverse_of: :module_references

  #
  # Validations
  #

  validates :module_instance,
            presence: true
  validates :reference,
            presence: true
  validates :reference_id,
            uniqueness: {
                scope: :module_instance_id,
                unless: :batched?
            }

  #
  # Instance Methods
  #

  # @!method module_instance=(module_instance)
  #   Sets module_instance.
  #
  #   @param module_instance [Metasploit::Cache::Module::Instance] {Metasploit::Cache::Module::Instance Module} with
  #     {#reference}.
  #   @return [void]

  # @!method reference=(reference)
  #   Sets {#reference}.
  #
  #   @param reference [Metasploit::Cache::Reference] {Metasploit::Cache::Reference reference} to exploit or
  #     proof-of-concept (PoC) code for module_instance.
  #   @return [void]
end