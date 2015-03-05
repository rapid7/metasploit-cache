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

  #
  # Instance Methods
  #

  # @!method module_target=(module_target)
  #   Sets {#module_target}.
  #
  #   @param module_target [Metasploit::Cache::Module::Target] the module target that supports {#platform}.
  #   @return [void]

  # @!method platform=(platform)
  #   Sets {#platform}.
  #
  #   @param platform [Metasploit::Cache::Platform] the platform supported by the {#module_target}.
  #   @return [void]

  Metasploit::Concern.run(self)
end