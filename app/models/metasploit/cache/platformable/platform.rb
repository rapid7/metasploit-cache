# Polymorphic join model between {#platform platforms} and {Metasploit::Cache::Encoder::Instance encoder},
# {Metasploit::Cache::Nop::Instance nop}, {Metasploit::Cache::Payload::Single::Instance single payload},
# {Metasploit::Cache::Payload::Stage::Instance stage payload},
# {Metasploit::Cache::Payload::Stager::Instance stager payload}, or {Metasploit::Cache::Post::Instance post}) Metasploit
# Modules or {Metasploit::Cache::Exploit::Target exploit Metasploit Module targets}.
class Metasploit::Cache::Platformable::Platform < ActiveRecord::Base
  #
  # Associations
  #

  # The platform supported by the `#platformable`.
  belongs_to :platform,
             class_name: 'Metasploit::Cache::Platform',
             inverse_of: :platformable_platforms

  #
  # Validates
  #

  validates :platform,
            presence: true

  Metasploit::Concern.run(self)
end