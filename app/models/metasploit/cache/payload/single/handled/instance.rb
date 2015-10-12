# A payload single handled Metasploit Module has both the payload single Metasploit Module ruby Module and the handler
# module mixed into a subclass of the payload base class.
class Metasploit::Cache::Payload::Single::Handled::Instance < ActiveRecord::Base
  extend ActiveSupport::Autoload

  include Metasploit::Cache::Batch::Root

  autoload :Persister

  #
  # Associations
  #

  # Payload single Metasploit Module class with the handler mixed in
  belongs_to :payload_single_handled_class,
             class_name: 'Metasploit::Cache::Payload::Single::Handled::Class',
             inverse_of: :payload_single_handled_instance

  #
  # Attributes
  #

  # @!attribute payload_single_handled_class_id
  #   Foreign key for {#payload_single_handled_class}.
  #
  #   @return [Integer]

  #
  # Validations
  #

  validates :payload_single_handled_class,
            presence: true
  validates :payload_single_handled_class_id,
            uniqueness: {
                unless: :batched?
            }

  Metasploit::Concern.run(self)
end