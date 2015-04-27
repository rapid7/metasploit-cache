# Namespace for encoder Metasploit Module cache metadata, including from
# {Metasploit::Cache::Encoder::Ancestor ancestors} and {Metasploit::Cache::Encoder::Class classes}.
module Metasploit::Cache::Encoder
  extend ActiveSupport::Autoload

  autoload :Ancestor
  autoload :Class
end