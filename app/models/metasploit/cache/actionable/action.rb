# Actions that can be performed by {Metasploit::Cache::Auxiliary::Instance#actions auxiliary Metasploit Modules}.
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

  Metasploit::Concern.run(self)
end