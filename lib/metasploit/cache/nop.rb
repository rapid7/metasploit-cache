# Namespace for nop Metasploit Module cache metadata, including from
# {Metasploit::Cache::Nop::Ancestor ancestors}, {Metasploit::Cache::Nop::Class classes}, and
# {Metasploit::Cache::Nop::Instance instances}.
module Metasploit::Cache::Nop
  extend ActiveSupport::Autoload

  autoload :Ancestor
  autoload :Class
  autoload :Instance
end