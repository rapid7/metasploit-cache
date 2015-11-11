# Namespace for modules for synchronizing the persistent cache and in-memory Metasploit Module class.
module Metasploit::Cache::Module::Class::Persister
  extend ActiveSupport::Autoload

  autoload :PersistentClass
  autoload :Rank
end