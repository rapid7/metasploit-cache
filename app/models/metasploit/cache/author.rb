# Author of one of more {#module_instances modules}.  An author can have 0 or more {#email_addresses} representing that
# the author's email may have changed over the history of metasploit-framework or they are submitting from a work and
# personal email for different code.
class Metasploit::Cache::Author < ActiveRecord::Base
  extend ActiveSupport::Autoload

  include Metasploit::Cache::Batch::Descendant
  include Metasploit::Model::Search
  include Metasploit::Model::Translation

  autoload :Persister

  #
  # Associations
  #

  # Joins to this author.
  has_many :contributions,
           as: :author,
           class_name: 'Metasploit::Cache::Contribution',
           dependent: :destroy,
           inverse_of: :author

  #
  # through: :contributions
  #

  # Email addresses used by this author across all {#contributions}.
  has_many :email_addresses,
           class_name: 'Metasploit::Cache::EmailAddress',
           through: :contributions

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