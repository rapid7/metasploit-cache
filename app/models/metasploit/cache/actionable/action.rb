# Actions that can be performed by {Metasploit::Cache::Auxiliary::Instance#actions auxiliary Metasploit Modules}.
class Metasploit::Cache::Actionable::Action < ActiveRecord::Base
  include Metasploit::Cache::Batch::Descendant

  #
  # CONSTANTS
  #

  # The record that has actions.
  belongs_to :actionable,
             polymorphic: true

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
end