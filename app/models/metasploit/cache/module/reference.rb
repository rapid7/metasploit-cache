# Join model between {Metasploit::Cache::Module::Instance modules} and {Metasploit::Cache::Reference references} that
# refer to the exploit in the modules.
class Metasploit::Cache::Module::Reference < ActiveRecord::Base
  include Metasploit::Cache::Batch::Descendant
  include Metasploit::Model::Translation

  #
  # Associations
  #

  # {Metasploit::Cache::Module::Instance Module} with {#reference}.
  belongs_to :module_instance, class_name: 'Metasploit::Cache::Module::Instance', inverse_of: :module_references

  # {Metasploit::Cache::Reference reference} to exploit or proof-of-concept (PoC) code for {#module_instance}.
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
  #   Sets {#module_instance}.
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

  Metasploit::Concern.run(self)
end