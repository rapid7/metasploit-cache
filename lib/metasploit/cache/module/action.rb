# Code shared between `Mdm::Module::Action` and `Metasploit::Framework::Module::Action`.
module Metasploit::Cache::Module::Action
  extend ActiveModel::Naming
  extend ActiveSupport::Concern

  include Metasploit::Model::Translation

  included do
    include ActiveModel::MassAssignmentSecurity
    include ActiveModel::Validations
    include Metasploit::Model::Search

    #
    # Mass Assignment Security
    #

    attr_accessible :name

    #
    # Search Attributes
    #

    search_attribute :name, :type => :string

    #
    # Validations
    #

    validates :module_instance,
              :presence => true
    validates :name,
              :presence => true
  end

  #
  # Associations
  #

  # @!attribute module_instance
  #   Module that has this action.
  #
  #   @return [Metasploit::Cache::Module::Instance]

  #
  # Attributes
  #

  # @!attribute [rw] name
  #   The name of this action.
  #
  #   @return [String]

  #
  # Instance Methods
  #

  # @!method module_instance=(module_instance)
  #   Sets {#module_instance}.
  #
  #   @param module_instance [Module::Cache::Module::Instance] Module that has this action.
  #   @return [void]

  # @!method name=(name)
  #   Sets {#name}.
  #
  #   @param name [String] Name of this action.
  #   @return [void]
end
