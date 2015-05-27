# A contribution an `#author` made using a given `#email_address` to a polymorphic `#contributable`.
class Metasploit::Cache::Contribution < ActiveRecord::Base
  #
  # Associations
  #

  # Name of the contributor.
  belongs_to :author,
             class_name: 'Metasploit::Cache::Author',
             inverse_of: :contributions

  # Email address {#author} used when writing this contribution.
  belongs_to :email_address,
             class_name: 'Metasploit::Cache::EmailAddress',
             inverse_of: :contributions

  #
  # Validations
  #

  validates :author,
            presence: true

  validates :email_address,
            presence: true

  Metasploit::Concern.run(self)
end