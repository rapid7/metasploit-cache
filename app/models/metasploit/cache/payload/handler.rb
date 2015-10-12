# Handles the local connection for a
# {Metasploit::Cache::Payload::Single::Unhandled::Instance single payload Metasploit Module} or
# {Metasploit::Cache::Payload::Stager::Instance stager payload Metasploit Module}.
class Metasploit::Cache::Payload::Handler < ActiveRecord::Base
  extend ActiveSupport::Autoload

  include Metasploit::Cache::Batch::Descendant

  autoload :Persister
  autoload :GeneralType
  autoload :Namespace

  #
  # Associations
  #

  # Single payload Metasploit Modules whose connections are handled by this handler.
  has_many :payload_single_unhandled_instances,
           class_name: 'Metasploit::Cache::Payload::Single::Unhandled::Instance',
           dependent: :destroy,
           inverse_of: :handler

  # Stager payload Metasploit Modules whose connections are handled by this handler.
  has_many :payload_stager_instances,
           class_name: 'Metasploit::Cache::Payload::Stager::Instance',
           dependent: :destroy,
           inverse_of: :handler

  #
  # Attributes
  #

  # @!attribute general_handler_type
  #   The {Metasploit::Cache::Payload::Handler::GeneralType general handler type}.
  #
  #   @return [String]

  # @!attribute handler_type
  #   The type of this handler.  Normally, in metasploit-framework, this is a Module method, `handler_type` that returns
  #   the underscored relative `Module#name`.
  #
  #   @return [String]

  # @!attribute name
  #   @note This name must be loadable with `String#constantize`.
  #
  #   The name of the handler ruby Module.
  #
  #   @return [String] a `Module#name`.

  #
  # Validations
  #

  validates :general_handler_type,
            inclusion: {
                in: Metasploit::Cache::Payload::Handler::GeneralType::ALL
            }
  validates :handler_type,
            presence: true
  validates :name,
            presence: true,
            uniqueness: {
                unless: :batched?
            }

  Metasploit::Concern.run(self)
end