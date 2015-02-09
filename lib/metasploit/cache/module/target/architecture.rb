# Model that joins {Metasploit::Cache::Architecture} and {Metasploit::Cache::Module::Target}.
module Metasploit::Cache::Module::Target::Architecture
  extend ActiveModel::Naming
  extend ActiveSupport::Concern

  include Metasploit::Model::Translation

  included do
    include ActiveModel::Validations

    #
    # Validations
    #

    validates :architecture,
              presence: true
    validates :module_target,
              presence: true
  end

  #
  # Associations
  #

  # @!attribute architecture
  #   The architecture supported by the {#module_target}.
  #
  #   @return [Metasploit::Cache::Architecture]

  # @!attribute module_target
  #   The module target that supports {#architecture}.
  #
  #   @return [Metasploit::Cache::Module::Target]

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
end
