# Joins {Metasploit::Cache::Module::Instance} and {Metasploit::Cache::Platform.}
module Metasploit::Cache::Module::Platform
  extend ActiveModel::Naming
  extend ActiveSupport::Concern

  include Metasploit::Model::Translation

  included do
    include ActiveModel::Validations

    #
    # Validations
    #

    validates :module_instance, :presence => true
    validates :platform, :presence => true
  end

  #
  # Associations
  #

  # @!attribute module_instance
  #   Module that supports {#platform}.
  #
  #   @return [Metasploit::Cache::Module::Instance]

  # @!attribute platform
  #  Platform supported by {#module_instance}.
  #
  #  @return [Metasploit::Cache::Platform]

  #
  # Instance Methods
  #

  # @!method module_instance=(module_instance)
  #   Sets {#module_instance}.
  #
  #   @param module_instance [Metasploit::Cache::Module::Instance] Module that supports {#platform}.
  #   @return [void]

  # @!method platform=(platform)
  #   Sets {#platform}.
  #
  #   @param platform [Metasploit::Cache::Platform] platform supported by {#module_instance}.
  #   @return [void]
end
