# {#platform} supported by {#module_target}.
class Metasploit::Cache::Module::Target::Platform < ActiveRecord::Base
  include Metasploit::Cache::Batch::Descendant
  include Metasploit::Model::Translation

  #
  # Associations
  #

  # The module target that supports {#platform}.
  belongs_to :module_target, class_name: 'Metasploit::Cache::Module::Target', inverse_of: :target_platforms

  # The platform supported by the {#module_target}.
  belongs_to :platform, class_name: 'Metasploit::Cache::Platform', inverse_of: :target_platforms

  #
  # Attributes
  #

  # @!method platform_id
  #   The primary key of associated {#platform}.
  #
  #   @return [Integer]

  #
  # Validations
  #

  validates :module_target,
            presence: true
  validates :platform,
            presence: true
  validates :platform_id,
            uniqueness: {
                scope: :module_target_id,
                unless: :batched?
            }

  Metasploit::Concern.run(self)
end