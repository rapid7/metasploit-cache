# Namespace for modules for synchronizing the persistent cache and in-memory Metasploit Module instances on
# their `#referencable_references` and `#platform` `#platforms`, respectively.
module Metasploit::Cache::Referencable::Persister
  extend ActiveSupport::Autoload

  autoload :ReferencableReferences
end