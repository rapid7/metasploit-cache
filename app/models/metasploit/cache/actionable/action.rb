# Actions that can be performed by {Metasploit::Cache::Auxiliary::Instance#actions auxiliary Metasploit Modules} or
# (optionally) by {Metasploit::Cache::Post::Instance#actions post Metasploit Modules}.
class Metasploit::Cache::Actionable::Action < ActiveRecord::Base
  include Metasploit::Cache::Batch::Descendant

  #
  # Associations
  #

  # The record that has actions.
  belongs_to :actionable,
             polymorphic: true

  #
  # Attributes
  #

  # @!attribute name
  #   The name of this action.
  #
  #   @return [String]

  #
  # Validations
  #

  validates :actionable,
            presence: true
  validates :name,
            presence: true,
            uniqueness: {
                scope: [
                    :actionable_type,
                    :actionable_id
                ],
                unless: :batched?
            }

  #
  # Instance Methods
  #

  # @!method name=(name)
  #   Sets {#name}.
  #
  #   @param name [String] the name of this action.
  #   @return [void]

  Metasploit::Concern.run(self)
end