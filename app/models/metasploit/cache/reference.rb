# Reference to a {#url} or a {#designation} maintained by an {#authority}, such as CVE, that describes an exposure or
# vulnerability on an `Mdm::Host` or that is exploited by a {#module_instances module}.
class Metasploit::Cache::Reference < ActiveRecord::Base
  include Metasploit::Cache::Batch::Descendant
  include Metasploit::Cache::Derivation
  include Metasploit::Model::Search
  include Metasploit::Model::Translation

  #
  #
  # Associations
  #
  #

  # The {Metasploit::Cache::Authority authority} that assigned {#designation}.
  belongs_to :authority, class_name: 'Metasploit::Cache::Authority', inverse_of: :references

  # Joins this {Metasploit::Cache::Reference} to {#module_instances}.
  has_many :module_references, class_name: 'Metasploit::Cache::Module::Reference', dependent: :destroy, inverse_of: :reference

  #
  # through: :module_references
  #

  # {Metasploit::Cache::Module::Instance Modules} that exploit this reference or describe a proof-of-concept (PoC) code
  # that the module is based on.
  has_many :module_instances, class_name: 'Metasploit::Cache::Module::Instance', through: :module_references

  #
  # Attributes
  #

  # @!attribute designation
  #   A designation (usually a string of numbers and dashes) assigned by {#authority}.
  #
  #   @return [String, nil]

  # @!attribute url
  #   URL to web page with information about referenced exploit.
  #
  #   @return [String, nil]

  #
  # Derivations
  #

  derives :url, validate: false

  #
  # Mass Assignment Security
  #

  attr_accessible :designation
  attr_accessible :url

  #
  # Search Attributes
  #

  search_attribute :designation, type: :string
  search_attribute :url, type: :string

  #
  # Validations
  #

  validates :designation,
            presence: {
                if: :authority?
            },
            nil: {
                unless: :authority?
            },
            uniqueness: {
                allow_nil: true,
                scope: :authority_id,
                unless: :batched?
            }
  validates :url,
            presence: {
                unless: :authority?
            },
            uniqueness: {
                allow_nil: true,
                unless: :batched?
            }

  #
  # Instance Methods
  #

  # Returns whether {#authority} is not `nil`.
  #
  # @return [true] unless {#authority} is `nil`.
  # @return [false] if {#authority} is `nil`.
  def authority?
    authority.present?
  end

  # Derives {#url} based how {#authority} routes {#designation designations} to a URL.
  #
  # @return [String, nil]
  def derived_url
    derived = nil

    if authority and designation.present?
      derived = authority.designation_url(designation)
    end

    derived
  end

  Metasploit::Concern.run(self)
end