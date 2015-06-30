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

  # Joins to this author.
  has_many :contributions,
           class_name: 'Metasploit::Cache::Contribution',
           dependent: :destroy,
           inverse_of: :author

  # Joins this to {#email_addresses} and {#module_instances}.
  has_many :module_authors, class_name: 'Metasploit::Cache::Module::Author', dependent: :destroy, inverse_of: :author

  #
  # through: :contributions
  #

  # Email addresses used by this author across all {#contributions}.
  has_many :email_addresses,
           class_name: 'Metasploit::Cache::EmailAddress',
           through: :contributions

  #
  # through: :module_authors
  #

  # Email addresses used by this author across all {#module_instances}.
  has_many :module_author_email_addresses,
           class_name: 'Metasploit::Cache::EmailAddress',
           through: :module_authors

  # Modules written by this author.
  has_many :module_instances, class_name: 'Metasploit::Cache::Module::Instance', through: :module_authors

  #
  # Attributes
  #

  # @!attribute name
  #   Full name (First + Last name) or handle of author.
  #
  #   @return [String]

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

  Metasploit::Concern.run(self)
end