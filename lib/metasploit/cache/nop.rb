# Namespace for nop Metasploit Module cache metadata, including from
# {Metasploit::Cache::Nop::Ancestor ancestors} and {Metasploit::Cache::Nop::Class classes}.
module Metasploit::Cache::Nop
  extend ActiveSupport::Autoload

  autoload :Ancestor
  autoload :Class
end