# {#architecture} supported by {#module_target}.
class Metasploit::Cache::Module::Target::Architecture < ActiveRecord::Base
  include Metasploit::Cache::Batch::Descendant
  include Metasploit::Model::Translation

  #
  # Associations
  #

  # The architecture supported by the {#module_target}.
  belongs_to :architecture, class_name: 'Metasploit::Cache::Architecture', inverse_of: :target_architectures

  # The module target that supports {#architecture}.
  belongs_to :module_target, class_name: 'Metasploit::Cache::Module::Target', inverse_of: :target_architectures

  #
  # Validations
  #

  validates :architecture,
            presence: true
  validates :architecture_id,
            uniqueness: {
                scope: :module_target_id,
                unless: :batched?
            }
  validates :module_target,
            presence: true

  #
  # Instance Methods
  #

  # @!method architecture=(architecture)
  #   Sets {#architecture}.
  #
  #   @param architecture [Metasploit::Cache::Architecture] an architecture supported by {#module_target}.
  #   @return [void]

  # @!method module_target=(module_target)
  #   Sets {#module_target}.
  #
  #   @param module_target [Metasploit::Cache::Module::Target] the module target that supports {#architecture}.
  #   @return [void]

  Metasploit::Concern.run(self)
end