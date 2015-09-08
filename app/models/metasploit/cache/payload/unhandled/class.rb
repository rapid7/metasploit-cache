# Superclass for all `Metasploit::Cache::Payload::*::Class` that represent Metasploit Modules without a handler in their
# ancestors.
class Metasploit::Cache::Payload::Unhandled::Class < Metasploit::Cache::Direct::Class
  extend ActiveSupport::Autoload

  autoload :AncestorCell
  autoload :Load
end