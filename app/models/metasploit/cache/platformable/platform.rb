# Polymorphic join model between {#platform platforms} and {Metasploit::Cache::Encoder::Instance encoder},
# {Metasploit::Cache::Nop::Instance nop}, {Metasploit::Cache::Payload::Single::Instance single payload},
# {Metasploit::Cache::Payload::Stage::Instance stage payload},
# {Metasploit::Cache::Payload::Stager::Instance stager payload}, or {Metasploit::Cache::Post::Instance post}) Metasploit
# Modules or {Metasploit::Cache::Exploit::Target exploit Metasploit Module targets}.
class Metasploit::Cache::Platformable::Platform < ActiveRecord::Base
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
                ]
            }

  Metasploit::Concern.run(self)
end