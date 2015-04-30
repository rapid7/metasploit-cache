# Superclass for all `Metasploit::Cache::Payload::*::Class` that have one
# {Metasploit::Cache::Direct::Class#ancestor ancestor}.
class Metasploit::Cache::Payload::Direct::Class < Metasploit::Cache::Direct::Class
  extend ActiveSupport::Autoload

  autoload :AncestorCell
  autoload :Load
end