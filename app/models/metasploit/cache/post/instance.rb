# Instance-level metadata for a post Metasploit Module.
class Metasploit::Cache::Post::Instance < ActiveRecord::Base
  #
  #
  # Associations
  #
  #

  # Joins {#architectures} to this post Metasploit Module.
  has_many :architecturable_architectures,
           class_name: 'Metasploit::Cache::Architecturable::Architecture',
           dependent: :destroy,
           inverse_of: :architecturable

  # The actions that are allowed for this post Metasploit Module.
  #
  # @return [ActiveRecord::Relation<Metasploit::Cache::Actionable::Action>]
  has_many :actions,
           as: :actionable,
           class_name: 'Metasploit::Cache::Actionable::Action',
           inverse_of: :actionable

  # @note The default action must be manually added to {#actions}.
  #
  # The (optional) default action for this post Metasploit Module.
  #
  # @return [Metasploit::Cache::Actionable::Action]
  belongs_to :default_action,
             class_name: 'Metasploit::Cache::Actionable::Action',
             inverse_of: :actionable

  # Joins {#licenses} to this post Metasploit Module.
  has_many :licensable_licenses,
           as: :licensable,
           class_name: 'Metasploit::Cache::Licensable::License',
           dependent: :destroy,
           inverse_of: :licensable

  # The class level metadata for this post Metasploit Module
  belongs_to :post_class,
             class_name: 'Metasploit::Cache::Post::Class',
             inverse_of: :post_instance

  # Joins {#references} to this auxiliary Metasploit Module.
  has_many :referencable_references,
           as: :referencable,
           class_name: 'Metasploit::Cache::Referencable::Reference',
           dependent: :destroy,
           inverse_of: :referencable

  #
  # through: :licensable_licenses
  #

  # The licenses covering the code in this auxiliary Metasploit Module.
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
  # through: :architecturable_architectures
  #

  # Architectures on which this Metasploit Module can run.
  has_many :architectures,
           class_name: 'Metasploit::Cache::Architecture',
           through: :architecturable_architectures

  #
  # Attributes
  #

  # @!attribute description
  #   The long-form human-readable description of this post Metasploit Module.
  #
  #   @return [String]

  # @!attribute disclosed_on
  #   The public disclosure date of the exploit exercised by this post Metasploit Module.
  #
  #   @return [Date]

  # @!attribute name
  #   The human-readable name of this post Metasploit Module.  This can be thought of as the title or summary of the
  #   Metasploit Module.
  #
  #   @return [String]

  # @!attribute post_class_id
  #   The foreign key for the {#post_class} association.
  #
  #   @return [Integer]

  # @!attribute privileged
  #   Whether this post Metasploit Module requires privileged access on the remote machine.
  #
  #   @return [true] privileged access is required.
  #   @return [false] privileged access is NOT required.

  #
  # Validations
  #

  validates :default_action,
            inclusion: {
                allow_nil: true,
                in: ->(post_instance){
                  post_instance.actions
                }
            }
  
  validates :description,
            presence: true

  validates :disclosed_on,
            presence: true

  validates :licensable_licenses,
            length: {
              minimum: 1
            }

  validates :name,
            presence: true

  validates :post_class,
            presence: true

  validates :post_class_id,
            uniqueness: true

  validates :privileged,
            inclusion: {
                in: [
                    false,
                    true
                ]
            }

  Metasploit::Concern.run(self)
end