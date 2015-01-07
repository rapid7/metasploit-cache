# Author of one of more {#module_instances modules}.  An author can have 0 or more {#email_addresses} representing that
# the author's email may have changed over the history of metasploit-framework or they are submitting from a work and
# personal email for different code.
class Metasploit::Cache::Author < ActiveRecord::Base
  include Metasploit::Cache::Batch::Descendant
  include Metasploit::Model::Search
  include Metasploit::Model::Translation

  #
  # Associations
  #

  # @!attribute module_authors
  #   Joins this to {#email_addresses} and {#module_instances}.
  #
  #   @return [ActiveRecord::Relation<Metasploit::Cache::Module::Author>]
  has_many :module_authors, class_name: 'Metasploit::Cache::Module::Author', dependent: :destroy, inverse_of: :author

  #
  # through: :module_authors
  #

  # @!attribute [r] email_addresses
  #   Email addresses used by this author across all {#module_instances}.
  #
  #   @return [ActiveRecord::Relation<Metasploit::Cache::EmailAddress>]
  has_many :email_addresses, class_name: 'Metasploit::Cache::EmailAddress', through: :module_authors

  # @!attribute [r] module_instances
  #   Modules written by this author.
  #
  #   @return [ActiveRecord::Relation<Metasploit::Cache::Module::Instance>]
  has_many :module_instances, class_name: 'Metasploit::Cache::Module::Instance', through: :module_authors

  #
  # Attributes
  #

  # @!attribute name
  #   Full name (First + Last name) or handle of author.
  #
  #   @return [String]

  #
  # Mass Assignment Security
  #

  attr_accessible :name

  #
  # Search Attributes
  #

  search_attribute :name, type: :string

  #
  # Validations
  #

  validates :name,
            presence: true,
            uniqueness: {
                unless: :batched?
            }

  #
  # Instance Methods
  #

  # @!method name=(name)
  #   Set the {#name}.
  #
  #   @param name [String] Full name (First + Last name) or handle of author.
  #   @return [void]

  Metasploit::Concern.run(self)
end