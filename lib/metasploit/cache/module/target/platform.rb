# Model that joins {Metasploit::Cache::Platform} and {Metasploit::Cache::Module::Target}.
module Metasploit::Cache::Module::Target::Platform
  extend ActiveModel::Naming
  extend ActiveSupport::Concern

  include Metasploit::Model::Translation

  included do
    include ActiveModel::Validations

    #
    # Validations
    #

    validates :module_target,
              presence: true
    validates :platform,
              presence: true
  end

  #
  # Associations
  #

  # @!attribute module_target
  #   The module target that supports {#platform}.
  #
  #   @return [Metasploit::Cache::Module::Target]

  # @!attribute platform
  #   The platform supported by the {#module_target}.
  #
  #   @return [Metasploit::Cache::Platform]

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
end
