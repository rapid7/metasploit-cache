# Code shared between `Mdm::EmailAddress` and `Metasploit::Framework::EmailAddress`.
module Metasploit::Cache::EmailAddress
  extend ActiveModel::Naming
  extend ActiveSupport::Concern

  include Metasploit::Model::Translation

  included do
    include ActiveModel::MassAssignmentSecurity
    include ActiveModel::Validations
    include Metasploit::Cache::Derivation
    include Metasploit::Model::Search

    #
    # Derivations
    #

    derives :domain, :validate => true
    derives :full, :validate => true
    derives :local, :validate => true

    #
    # Mass Assignment Security
    #

    attr_accessible :domain
    attr_accessible :full
    attr_accessible :local

    #
    # Search Attributes
    #

    search_attribute :domain, :type => :string
    search_attribute :full, :type => :string
    search_attribute :local, :type => :string

    #
    # Validations
    #

    validates :domain, :presence => true
    validates :local, :presence => true
  end

  #
  # Associations
  #

  # @!attribute module_authors
  #   Credits where {#authors} used this email address for {#module_instances modules}.
  #
  #   @return [Array<Metasploit::Cache::Module::Author>]

  # @!attribute [r] authors
  #   Authors that used this email address.
  #
  #   @return [Array<Metasploit::Cache::Author>]

  # @!attribute [r] module_instances
  #   Modules where this email address was used.
  #
  #   @return [Array<Metasploit::Module::Instance>]

  #
  # Attributes
  #

  # @!attribute [rw] domain
  #   The domain part of the email address after the `'@'`.
  #
  #   @return [String]

  # @!attribute full
  #   The full email address.
  #
  #   @return [String] <{#local}>@<{#domain}>

  # @!attribute local
  #   The local part of the email address before the `'@'`.
  #
  #   @return [String]

  #
  # Instance Methods
  #

  # Derives {#domain} from {#full}
  #
  # @return [String] if {#full} is present
  # @return [nil] if {#full} is not present
  def derived_domain
    domain = nil

    if full.present?
      _local, domain = full.split('@', 2)
    end

    domain
  end

  # Derives {#full} from {#domain} and {#local}
  #
  # @return [String]
  def derived_full
    if domain.present? && local.present?
      "#{local}@#{domain}"
    end
  end

  # Derives {#local} from {#full}.
  #
  # @return [String] if {#full} is present
  # @return [nil] if {#full} is not present
  def derived_local
    local = nil

    if full.present?
      local, _domain = full.split('@', 2)
    end

    local
  end

  # @!method domain=(domain)
  #   Sets {#domain}.
  #
  #   @param domain [String] The domain part of the email address after the `'@'`.
  #   @return [void]

  # @!method full=(full)
  #   Sets {#full}.
  #
  #   @param full [String] <{#local}>@<{#domain}>
  #   @return [void]

  # @!method local=(local)
  #   Sets {#local}.
  #
  #   @param local [String] The local part of the email address before the `'@'`.
  #   @return [void]

  # @!method module_authors=(module_authors)
  #   Sets {#module_authors}.
  #
  #   @param module_authors [Array<Metasploit::Cache::Module::Authors>] Credits where {#authors} used this email address
  #     for {#module_instances modules}.
  #   @return [void]
end
