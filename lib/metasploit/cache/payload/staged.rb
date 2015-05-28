# Namespace for staged payload Metasploit Module cache metadata, including
# {Metasploit::Cache::Payload::Staged::Class classes}.
#
# A staged payload Metasploit Module that combines a stager payload Metasploit Module that downloads a staged payload
# Metasploit Module.
#
# The stager and stage payload must be compatible.  A stager and stage are compatible if they share some subset of
# architectures and platforms.
module Metasploit::Cache::Payload::Staged
  extend ActiveSupport::Autoload

  autoload :Class
end