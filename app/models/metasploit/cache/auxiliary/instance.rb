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

  #
  # Validations
  #

  validates :actions,
            length: {
                minimum: 1
            }
  validates :auxiliary_class,
            presence: true
end