# A payload single handled Metasploit Module has both the payoad single Metasploit Module ruby Module and the handler
# module mixed into a subclass of the payload base class.
class Metasploit::Cache::Payload::Single::Handled::Class < ActiveRecord::Base
  extend ActiveSupport::Autoload

  include Metasploit::Cache::Batch::Root
  include Metasploit::Cache::Module::Class::Namable

  autoload :Ephemeral
  autoload :Load

  #
  # Associations
  #

  # Instance of this payload single Metasploit Module with the handler mixed in.
  has_one :payload_single_handled_instance,
          class_name: 'Metasploit::Cache::Payload::Single::Handled::Instance',
          foreign_key: :payload_single_handled_class_id,
          inverse_of: :payload_single_handled_class

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

  #
  # Instance Methods
  #

  # Derives reference name from Metasploit Module from {Metasploit::Cache::Module::Ancestor#relative_path}.
  #
  # @return [nil] if {#payload_single_unhandled_instnace} is `nil`.
  # @return [nil] if {#paylaod_single_unhandled_instance}
  #   {Metasploit::Cache::Payload::Single::Unhandled::Instance#payload_unhandled_class} is `nil`.
  # @return [nil] if {#paylaod_single_unhandled_instance}
  #   {Metasploit::Cache::Payload::Single::Unhandled::Instance#payload_unhandled_class}
  #   {Metasploit::Cache::Payload::Single::Unhandled::Class#ancestor} is `nil`.
  # @return [String] Relative path with module type directory, payload type directory, and file extension removed.
  def reference_name
    ancestor = payload_single_unhandled_instance.try!(:payload_single_unhandled_class).try!(:ancestor)

    if ancestor
      Metasploit::Cache::Module::Class::Namable.reference_name relative_file_names: ancestor.relative_file_names,
                                                               scoping_levels: 2
    end
  end

  Metasploit::Concern.run(self)
end