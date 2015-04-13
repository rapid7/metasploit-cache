# Namespace for single payload Metasploit Module cache metadata, including
# {Metasploit::Cache::Payload::Single::Ancestor ancestors}, {Metasploit::Cache::Payload::Single::Class classes},
# {Metasploit::Cache::Payload::Single::Instance instances}.
module Metasploit::Cache::Payload::Single
  extend ActiveSupport::Autoload

  autoload :Ancestor
  autoload :Class
  autoload :Instance
end