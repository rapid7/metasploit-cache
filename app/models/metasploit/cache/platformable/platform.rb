# Polymorphic join model between {#platform platforms} and {Metasploit::Cache::Encoder::Instance encoder},
# {Metasploit::Cache::Nop::Instance nop}, {Metasploit::Cache::Payload::Single::Instance single payload},
# {Metasploit::Cache::Payload::Stage::Instance stage payload},
# {Metasploit::Cache::Payload::Stager::Instance stager payload}, or {Metasploit::Cache::Post::Instance post}) Metasploit
# Modules or {Metasploit::Cache::Exploit::Target exploit Metasploit Module targets}.
class Metasploit::Cache::Platformable::Platform < ActiveRecord::Base
  include Metasploit::Cache::Batch::Descendant

  #
  # Associations
  #

  # The thing that supports {#platform}.
  belongs_to :platformable,
             inverse_of: :platformable_platforms,
             polymorphic: true

  # The platform supported by the `#platformable`.
  belongs_to :platform,
             class_name: 'Metasploit::Cache::Platform',
             inverse_of: :platformable_platforms

  #
  # Attributes
  #

  # @!attribute platform_id
  #   The foreign key for {#platform}.
  #
  #   @return [Integer]

  #
  # Validates
  #

  validates :platformable,
            presence: true
  validates :platform,
            presence: true
  validates :platform_id,
            uniqueness: {
                scope: [
                    :platformable_type,
                    :platformable_id
                ],
                unless: :batched?
            }

  #
  # Instance Methods
  #

  # @!method platform_id=(platform_id)
  #   Sets {#platform_id} and invalidates the cached {#platform} so it is reloaded on next access.
  #
  #   @param platform_id [Integer] The foreign key used to load {#platform}.
  #   @return [void]

  Metasploit::Concern.run(self)
end