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
  # Attributes
  #

  # @!method architecture_id
  #   The primary key of the associated {#architecture}.
  #
  #   @return [Integer]

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

  Metasploit::Concern.run(self)
end