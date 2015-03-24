# Namespace for encoder Metasploit Module cache metadata, including from
# {Metasploit::Cache::Encoder::Ancestor ancestors}, {Metasploit::Cache::Encoder::Class classes}, and
# {Metasploit::Cache::Encoder::Instance instnaces}.
module Metasploit::Cache::Encoder
  extend ActiveSupport::Autoload

  autoload :Ancestor
  autoload :Class
  autoload :Instance
end