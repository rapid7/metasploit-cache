# Namespace for modules for synchronizing the persistent cache and in-memory Metasploit Module instances on
# their `#architecturable_architectures` and `#arch`, respectively.
module Metasploit::Cache::Architecturable::Ephemeral
  extend ActiveSupport::Autoload

  autoload :ArchitecturableArchitectures
end