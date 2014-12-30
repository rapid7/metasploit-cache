# Code shared between `Mdm::Author` and `Metasploit::Framework::Author`.
module Metasploit::Cache::Author
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

    validates :name, :presence => true
  end

  #
  # Associations
  #

  # @!attribute [r] email_addresses
  #   Email addresses used by this author across all {#module_instances}.
  #
  #   @return [Array<Metasploit::Cache::EmailAddress>]

  # @!attribute [r] module_instances
  #   Modules written by this author.
  #
  #   @return [Array<Metasploit::Cache::Module::Instance>]

  #
  # Attributes
  #

  # @!attribute name
  #   Full name (First + Last name) or handle of author.
  #
  #   @return [String]

  #
  # Instance Methods
  #

  # @!method name=(name)
  #   Set the {#name}.
  #
  #   @param name [String] Full name (First + Last name) or handle of author.
  #   @return [void]
end
