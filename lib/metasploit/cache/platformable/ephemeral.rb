# Namespace for modules for synchronizing the persistent cache and in-memory Metasploit Module instances on
# their `#platformable_platforms` and `#platform` `#platforms`, respectively.
module Metasploit::Cache::Platformable::Ephemeral
  extend ActiveSupport::Autoload

  autoload :PlatformablePlatforms
end