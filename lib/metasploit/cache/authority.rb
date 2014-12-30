# Code shared between `Mdm::Authority` and `Metasploit::Framework::Authority`.
module Metasploit::Cache::Authority
  extend ActiveModel::Naming
  extend ActiveSupport::Autoload
  extend ActiveSupport::Concern

  include Metasploit::Model::Translation

  autoload :Bid
  autoload :Cve
  autoload :Msb
  autoload :Osvdb
  autoload :Pmasa
  autoload :Secunia
  autoload :UsCertVu
  autoload :Waraxe
  autoload :Zdi

  included do
    include ActiveModel::MassAssignmentSecurity
    include ActiveModel::Validations
    include Metasploit::Model::Search

    #
    # Mass Assignment Security
    #

    attr_accessible :abbreviation
    attr_accessible :obsolete
    attr_accessible :summary
    attr_accessible :url

    #
    # Search Attributes
    #

    search_attribute :abbreviation, :type => :string

    #
    # Validations
    #

    validates :abbreviation,
              :presence => true
  end

  #
  # Associations
  #

  # @!attribute references
  #   {Metasploit::Cache::Reference References} that use this authority's scheme for their
  #   {Metasploit::Cache::Reference#authority}.
  #
  #   @return [Array<Metasploit::Cache::Reference>]

  # @!attribute [r] module_instances
  #   {Metasploit::Cache::Module::Instance Modules} that have a reference with this authority.
  #
  #   @return [Array<Metasploit::Cache::Module::Instance>]

  # @!attribute [r] vulns
  #   Vulnerabilities that have a reference under this authority.
  #
  #   @return [Array<Metasploit::Cache::Vuln>]

  #
  # Attributes
  #

  # @!attribute abbreviation
  #   Abbreviation or initialism for authority, such as CVE for 'Common Vulnerability and Exposures'.
  #
  #   @return [String]

  # @!attribute obsolete
  #   Whether this authority is obsolete and no longer exists on the internet.
  #
  #   @return [false]
  #   @return [true] {#url} may be `nil` because authory no longer has a web site.

  # @!attribute summary
  #   An expansion of the {#abbreviation}.
  #
  #   @return [String, nil]

  # @!attribute url
  #   URL to the authority's home page or root URL for their {#references} database.
  #
  #   @return [String, nil]

  #
  # Instance Methods
  #

  # @!method abbreviation=(abbreviation)
  #   Sets {#abbreviation}.
  #
  #   @param abbreviation [String] Abbreviation or initialism for authority, such as CVE for
  #     'Common Vulnerability and Exposures'.
  #   @return [void]

  # @!method obsolete=(obsolete)
  #   Sets {#obsolete}.
  #
  #   @param obsolete [Boolean] `true` if this authority is obsolete and no longer exists on the internet; otherwise
  #     `false`.
  #   @return [void]

  # Returns the {Metasploit::Cache::Reference#url URL} for a {Metasploit::Cache::Reference#designation designation}.
  #
  # @param designation [String] {Metasploit::Cache::Reference#designation}.
  # @return [String] {Metasploit::Cache::Reference#url}
  # @return [nil] if this {Metasploit::Cache::Authority} is {#obsolete}.
  # @return [nil] if this {Metasploit::Cache::Authority} does have a way to derive URLS from designations.
  def designation_url(designation)
    url = nil

    if extension
      url = extension.designation_url(designation)
    end

    url
  end

  # Returns module that include authority specific methods.
  #
  # @return [Module] if {#abbreviation} has a corresponding module under the Metasploit::Cache::Authority namespace.
  # @return [nil] otherwise.
  def extension
    begin
      extension_name.constantize
    rescue NameError
      nil
    end
  end

  # Returns name of module that includes authority specific methods.
  #
  # @return [String] unless {#abbreviation} is blank.
  # @return [nil] if {#abbreviation} is blank.
  def extension_name
    extension_name = nil

    unless abbreviation.blank?
      # underscore before camelize to eliminate -'s
      relative_model_name = abbreviation.underscore.camelize
      # don't scope to self.class.name so that authority extension are always resolved the same in Mdm and
      # Metasploit::Framework.
      extension_name = "Metasploit::Cache::Authority::#{relative_model_name}"
    end

    extension_name
  end

  # @!method references=(references)
  #   Sets {#references}.
  #
  #   @param references [Array<Metasploit::Cache::Reference>] {Metasploit::Cache::Reference References} that use this
  #     authority's scheme for their {Metasploit::Cache::Reference#authority}.
  #   @return [void]

  # @!method summary=(summary)
  #   Sets {#summary}.
  #
  #   @param summary [String] An expansion of the {#abbreviation}.
  #   @return [void]

  # @!method url=(url)
  #   Sets {#url}.
  #
  #   @param url [String]  URL to the authority's home page or root URL for their {#references} database.
  #   @return [void]
end
