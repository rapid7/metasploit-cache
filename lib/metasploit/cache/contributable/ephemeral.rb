# Namespace for modules for synchronizing the persistent cache and in-memory Metasploit Module instances on their
# contributions and authors.
module Metasploit::Cache::Contributable::Ephemeral
  extend ActiveSupport::Autoload

  autoload :Contributions
end