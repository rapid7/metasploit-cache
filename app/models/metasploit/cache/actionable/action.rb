# Actions that can be performed by {Metasploit::Cache::Auxiliary::Instance#actions auxiliary Metasploit Modules}.
class Metasploit::Cache::Actionable::Action < ActiveRecord::Base
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
end