# Polymorphic join model between {#architecture architectures} and ({Metasploit::Cache::Encoder::Instance encoder},
# {Metasploit::Cache::Nop::Instance nop}, {Metasploit::Cache::Payload::Single::Instance single payload},
# {Metasploit::Cache::Payload::Stage::Instance stage payload},
# {Metasploit::Cache::Payload::Stager::Instance stager payload}, or {Metasploit::Cache::Post::Instance post}) Metasploit
# Modules or {Metasploit::Cache::Exploit::Target exploit Metasploit Module targets}.
class Metasploit::Cache::Architecturable::Architecture < ActiveRecord::Base
  include Metasploit::Cache::Batch::Descendant

  #
  # Associations
  #

  # The thing that supports {#architecture}.
  belongs_to :architecturable,
             inverse_of: :architecturable_architectures,
             polymorphic: true

  # The architecture supported by the {#architecturable}.
  belongs_to :architecture,
             class_name: 'Metasploit::Cache::Architecture',
             inverse_of: :architecturable_architectures

  #
  # Attributes
  #

  # @!attribute architecture_id
  #   The foreign key for {#architecture}.
  #
  #   @return [Integer]

  #
  # Validations
  #

  validates :architecturable,
            presence: true
  validates :architecture,
            presence: true
  validates :architecture_id,
            uniqueness: {
                scope: [
                    :architecturable_type,
                    :architecturable_id
                ],
                unless: :batched?
            }

  #
  # Instance Methods
  #

  # @!method architecture_id=(architecture_id)
  #   Sets {#architecture_id} and invalidates cached {#architecture} so it is reloaded on next access.
  #
  #   @param architecture_id [Integer] Primary key of {#architecture}.
  #   @return [void]

  Metasploit::Concern.run(self)
end