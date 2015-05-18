# Instance-level metadata for a post Metasploit Module.
class Metasploit::Cache::Post::Instance < ActiveRecord::Base
  #
  # Associations
  #

  # The class level metadata for this post Metasploit Module
  belongs_to :post_class,
             class_name: 'Metasploit::Cache::Post::Class',
             inverse_of: :post_instance

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

  validates :description,
            presence: true
  validates :disclosed_on,
            presence: true
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