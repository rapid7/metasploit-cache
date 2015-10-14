# Connects an in-memory payload stager Metasploit Module ruby Module to its persisted
# {Metasploit::Cache::Payload::Stager::Ancestor}.
class Metasploit::Cache::Payload::Stager::Ancestor::Persister < Metasploit::Cache::Module::Ancestor::Persister
  extend ActiveSupport::Autoload

  autoload :Handler

  #
  # CONSTANTS
  #

  # Modules used to synchronize attributes and associations before persisting to database
  SYNCHRONIZERS = [
      self::Handler
  ]
end