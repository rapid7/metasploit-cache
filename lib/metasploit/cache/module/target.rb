# Code shared between `Mdm::Module::Target` and `Metasploit::Framework::Module::Target`.
module Metasploit::Cache::Module::Target
  extend ActiveModel::Naming
  extend ActiveSupport::Autoload
  extend ActiveSupport::Concern

  include Metasploit::Model::Translation

  autoload :Architecture
  autoload :Platform

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
    # Validators
    #

    validates :module_instance, :presence => true
    validates :name, :presence => true
    validates :target_architectures, presence: true
    validates :target_platforms, presence: true
  end

  #
  # Associations
  #

  # @!attribute [r] architectures
  #   Architectures that this target supports, either by being declared specifically for this target or because
  #   this target did not override architectures and so inheritted the architecture set from the class.
  #
  #   @return [Array<Metasploit::Cache::Architecture>]

  # @!attribute module_instance
  #   Module where this target was declared.
  #
  #   @return [Metasploit::Cache::Module::Instance]

  # @!attribute [r] platforms
  #   Platforms that this target supports, either by being declared specifically for this target or because this
  #   target did not override platforms and so inheritted the platform set from the class.
  #
  #   @return [Array<Metasploit::Cache::Platform>]

  # @!attribute target_architectures
  #   Joins this target to its {#architectures}
  #
  #   @return [Array<Metasploit::Cache::Module::Target::Architecture]

  # @!attribute target_platforms
  #   Joins this target to its {#platforms}
  #
  #   @return [Array<Metasploit::Cache::Module::Target::Platform>]

  #
  # Attributes
  #

  # @!attribute name
  #   The name of this target.
  #
  #   @return [String]

  #
  # Instance Methods
  #

  # @!method module_instance=(module_instance)
  #   Sets {#module_instance}.
  #
  #   @param module_instance [Metasploit::Cache::Module::Instance] module where this target was declared.
  #   @return [void]

  # @!method name=(name)
  #   Sets {#name}.
  #
  #   @param name [String] name of this target.
  #   @return [void]

  # @!method target_architectures=(target_architectures)
  #   Sets {#target_architectures}.
  #
  #   @param target_architectures [Array<Metasploit::Cache::Module::Target::Architecture>] joins this target ot its
  #     {#architectures}.
  #   @return [void]

  # @!method target_platforms=(target_platforms)
  #   Sets {#target_platforms}.
  #
  #   @param target_platforms [Array<Metasploit::Cache::Module::Target::Platform>] joins this target to its
  #     {#platforms}.
  #   @return [void]
end
