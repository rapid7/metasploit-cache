# Join model that maps a {Metasploit::Cache::Module::Instance model} to a supported {Metasploit::Cache::Module::Architecture architecture}.
class Metasploit::Cache::Module::Architecture < ActiveRecord::Base
  include Metasploit::Cache::Batch::Descendant
  include Metasploit::Model::Translation

  #
  # Associations
  #

  # {Metasploit::Cache::Module::Architecture Architecture} supported by {#module_instance}.
  belongs_to :architecture, class_name: 'Metasploit::Cache::Architecture', inverse_of: :module_architectures

  # {Metasploit::Cache::Module::Instance} that supports {#architecture}.
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

  Metasploit::Concern.run(self)
end
