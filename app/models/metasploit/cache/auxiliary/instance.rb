# Instance-level metadata for an auxiliary Metasploit Module.
class Metasploit::Cache::Auxiliary::Instance < ActiveRecord::Base
  #
  #
  # Associations
  #
  #

  # The actions that are allowed for the auxiliary Metasploit Module.
  #
  # @return [ActiveRecord::Relation<Metasploit::Cache::Actionable::Action>]
  has_many :actions,
           as: :actionable,
           class_name: 'Metasploit::Cache::Actionable::Action',
           dependent: :destroy,
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

  # Joins {#licenses} to this auxiliary Metasploit Module.
  has_many :licensable_licenses,
           as: :licensable,
           class_name: 'Metasploit::Cache::Licensable::License',
           dependent: :destroy,
           inverse_of: :licensable

  # Joins {#references} to this auxiliary Metasploit Module
  has_many :referencable_references,
           as: :referencable,
           class_name: 'Metasploit::Cache::Referencable::Reference',
           dependent: :destroy,
           inverse_of: :referencable

  #
  # through: :licensable_licenses
  #

  # The {Metasploit::Cache::License} for the code in this auxiliary Metasploit Module.
  has_many :licenses,
           class_name: 'Metasploit::Cache::License',
           through: :licensable_licenses

  #
  # through: :referencable_references
  #

  # The {Metasploit::Cache::Reference} for the content in this auxiliary Metasploit Module.
  has_many :references,
           class_name: 'Metasploit::Cache::Reference',
           through: :referencable_references

  #
  # Attributes
  #

  # @!attribute description
  #   The long-form human-readable description of this auxiliary Metasploit Module.
  #
  #   @return [String]

  # @!attribute disclosed_on
  #   The date when the bug this Metasploit Module exercises was disclosed publicly.
  #
  #   @return [Date]
  #   @return [nil] No bug is exercised by this Metasploit Module, it uses the normal behavior of a client or service.

  # @!attribute name
  #   The human-readable name of this auxiliary Metasploit Module.  This can be thought of as the title or summary of
  #   the Metasploit Module.
  #
  #   @return [String]

  # @!attribute stance
  #   Whether this Metasploit Module is aggressive or passive.
  #
  #   @return ['aggressive'] This Metasploit Module connects to a remote server, so the Metasploit Module is a client
  #     exploiting a server.
  #   @return ['passive'] This Metasploit Module waits for remote clients to connect to it, so the Metasploit Module is
  #     a server exploiting clients.

  #
  # Validations
  #

  validates :actions,
            length: {
                minimum: 1
            }

  validates :auxiliary_class,
            presence: true
  
  validates :default_action,
            inclusion: {
                allow_nil: true,
                in: ->(auxiliary_instance){
                  auxiliary_instance.actions
                }
            }

  validates :description,
            presence: true

  validates :licensable_licenses,
            length: {
              minimum: 1
            }

  validates :name,
            presence: true

  validates :stance,
            inclusion: {
                in: Metasploit::Cache::Module::Stance::ALL
            }

  #
  # Instance Methods
  #

  private

  # Validates that {#default_action}, when it is set, is in {#actions}.
  #
  # @return [void]
  def actions_contains_default_action
    unless default_action.nil? || actions.include?(default_action)
      errors.add(:actions, :does_not_contain_default_action)
    end
  end

  # Switch back to public for load hooks
  public

  Metasploit::Concern.run(self)
end