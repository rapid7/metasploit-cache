# A contribution an `#author` made using a given `#email_address` to a polymorphic `#contributable`.
class Metasploit::Cache::Contribution < ActiveRecord::Base
  include Metasploit::Cache::Batch::Descendant

  #
  # Associations
  #

  # Name of the contributor.
  belongs_to :author,
             class_name: 'Metasploit::Cache::Author',
             inverse_of: :contributions

  belongs_to :contributable,
             polymorphic: true

  # Email address {#author} used when writing this contribution.
  belongs_to :email_address,
             class_name: 'Metasploit::Cache::EmailAddress',
             inverse_of: :contributions

  #
  # Attributes
  #

  # @!attribute author_id
  #   Foreign key for {#author}.
  #
  #   @return [Integer]

  # @!attribute email_address_id
  #   Foreign key for {#email_address}.
  #
  #   @return [Integer]
  #   @return [nil] if no {#email_address}.

  #
  # Validations
  #

  validates :author,
            presence: true

  validates :author_id,
            uniqueness: {
                scope: [
                    :contributable_type,
                    :contributable_id
                ],
                unless: :batched?
            }

  validates :contributable,
            presence: true

  validates :email_address_id,
            uniqueness: {
                allow_nil: true,
                scope: [
                    :contributable_type,
                    :contributable_id
                ],
                unless: :batched?
            }

  #
  # Instance Methods
  #

  # @!method author_id=(author_id)
  #   Sets {#author_id} and invalidates cached {#author} so it is reloaded on next access.
  #
  #   @param author_id [Integer]
  #   @return [void]

  # @!method email_address_id=(email_address_id)
  #   Sets {#email_address_id} and invalidates cached {#email_address} so it is reloaded on next access.
  #
  #   @param email_address_id [Integer]
  #   @return [void]

  Metasploit::Concern.run(self)
end