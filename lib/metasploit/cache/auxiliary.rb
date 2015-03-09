# Namespace for auxiliary Metasploit Module cache metadata, including from
# {Metasploit::Cache::Auxiliary::Ancestor ancestors} and {Metasploit::Cache::Auxiliary::Class classes}.
module Metasploit::Cache::Auxiliary
  extend ActiveSupport::Autoload

  autoload :Ancestor
  autoload :Class
end