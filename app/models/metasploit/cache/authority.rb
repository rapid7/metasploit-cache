# An authority that supplies {Metasploit::Cache::Reference references}, such as CVE.
class Metasploit::Cache::Authority < ActiveRecord::Base
  extend ActiveSupport::Autoload

  include Metasploit::Cache::Batch::Descendant
  include Metasploit::Model::Search
  include Metasploit::Model::Translation

  autoload :Bid
  autoload :Cve
  autoload :Cwe
  autoload :Edb
  autoload :Msb
  autoload :Osvdb
  autoload :Pmasa
  autoload :Secunia
  autoload :Seed
  autoload :UsCertVu
  autoload :Waraxe
  autoload :Wpvdb
  autoload :Zdi

  #
  #
  # Associations
  #
  #

  # {Metasploit::Cache::Reference References} that use this authority's scheme for their
  # {Metasploit::Cache::Reference#authority}.
  has_many :references, class_name: 'Metasploit::Cache::Reference', dependent: :destroy, inverse_of: :authority

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
  #   @return [true] {#url} may be `nil` because authority no longer has a web site.

  # @!attribute summary
  #   An expansion of the {#abbreviation}.
  #
  #   @return [String, nil]

  # @!attribute url
  #   URL to the authority's home page or root URL for their {#references} database.
  #
  #   @return [String, nil]

  #
  # Search Attributes
  #

  search_attribute :abbreviation, :type => :string

  #
  # Validations
  #

  validates :abbreviation,
            presence: true,
            uniqueness: {
                unless: :batched?
            }
  validates :summary,
            uniqueness: {
                allow_nil: true,
                unless: :batched?
            }
  validates :url,
            uniqueness: {
                allow_nil: true,
                unless: :batched?
            }

  #
  # Instance Methods
  #

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
      extension_name = "#{self.class.name}::#{relative_model_name}"
    end

    extension_name
  end

  Metasploit::Concern.run(self)
end
