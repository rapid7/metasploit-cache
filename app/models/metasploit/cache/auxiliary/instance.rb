# Instance-level metadata for an auxiliary Metasploit Module.
class Metasploit::Cache::Auxiliary::Instance < ActiveRecord::Base
  #
  # Associations
  #

  # The actions that are allowed for the auxiliary Metasploit Module.
  #
  # @return [ActiveRecord::Relation<Metasploit::Cache::Actionable::Action>]
  has_many :actions,
           as: :actionable,
           class_name: 'Metasploit::Cache::Actionable::Action',
           inverse_of: :actionable

  # The class-level metadata for this instance metadata.
  #
  # @return [Metasploit::Cache::Auxiliary::Class]
  belongs_to :auxiliary_class,
             class_name: 'Metasploit::Cache::Auxiliary::Class',
             inverse_of: :auxiliary_instance

  # @note The default action must be manually added to {#actions}.
  #
  # The (optional) default action for the auxiliary Metasploit Module.
  #
  # @return [Metasploit::Cache::Actionable::Action]
  belongs_to :default_action,
             class_name: 'Metasploit::Cache::Actionable::Action',
             inverse_of: :actionable

  #
  #
  # Validations
  #
  #

  #
  # Method Validations
  #

  validate :actions_contains_default_action

  #
  # Attribute Validations
  #

  validates :actions,
            length: {
                minimum: 1
            }
  validates :auxiliary_class,
            presence: true
  validates :description,
            presence: true

  private

  # Validates that {#default_action}, when it is set, is in {#actions}.
  #
  # @return [void]
  def actions_contains_default_action
    unless default_action.nil? || actions.include?(default_action)
      errors.add(:actions, :does_not_contain_default_action)
    end
  end
end