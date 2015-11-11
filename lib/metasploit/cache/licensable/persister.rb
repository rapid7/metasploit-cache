# Namespace for modules for synchronizing the persistent cache and in-memory Metasploit Module instances on their
# licenses
module Metasploit::Cache::Licensable::Persister
  extend ActiveSupport::Autoload

  autoload :LicensableLicenses
end