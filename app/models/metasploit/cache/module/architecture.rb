# Join model that maps a {Metasploit::Cache::Module::Instance model} to a supported {Metasploit::Cache::Module::Architecture architecture}.
class Metasploit::Cache::Module::Architecture < ActiveRecord::Base
  include Metasploit::Cache::Batch::Descendant
  include Metasploit::Model::Translation

  #
  # Associations
  #

  # @!attribute architecture
  #   {Metasploit::Cache::Module::Architecture Architecture} supported by {#module_instance}.
  #
  #   @return [Metasploit::Cache::Architecture]
  belongs_to :architecture, class_name: 'Metasploit::Cache::Architecture', inverse_of: :module_architectures

  # @!attribute module_instance
  #
  #
  #   @return [Metasploit::Cache::Module::Instance]
  belongs_to :module_instance, class_name: 'Metasploit::Cache::Module::Instance', inverse_of: :module_architectures

  #
  # Mass Assignment Security
  #

  attr_accessible :architecture
  attr_accessible :module_instance

  #
  # Validations
  #

  validates :architecture,
            presence: true
  validates :architecture_id,
            uniqueness: {
                scope: :module_instance_id,
                unless: :batched?
            }
  validates :module_instance,
            presence: true

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

  Metasploit::Concern.run(self)
end
