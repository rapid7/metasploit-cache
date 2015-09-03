# A payload single handled Metasploit Module has both the payoad single Metasploit Module ruby Module and the handler
# module mixed into a subclass of the payload base class.
class Metasploit::Cache::Payload::Single::Handled::Class < ActiveRecord::Base
  extend ActiveSupport::Autoload

  include Metasploit::Cache::Batch::Root

  autoload :Ephemeral
  autoload :Load

  #
  # Associations
  #

  # Payload single Metasploit Module without the handler mixed in, but does supply the handler module.
  belongs_to :payload_single_unhandled_instance,
             class_name: 'Metasploit::Cache::Payload::Single::Unhandled::Instance',
             inverse_of: :payload_single_handled_class

  #
  # Attributes
  #

  # @!attribute payload_single_unhandled_instance_id
  #   Foreign key for {#payload_single_unhandled_instance}.
  #
  #   @return [Integer]

  #
  # Validations
  #

  validates :payload_single_unhandled_instance,
            presence: true
  validates :payload_single_unhandled_instance_id,
            uniqueness: {
                unless: :batched?
            }

  Metasploit::Concern.run(self)
end