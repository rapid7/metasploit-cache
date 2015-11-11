# Abstract namespace for records that can be a {Metasploit::Cache::Contribution#contributable}.
module Metasploit::Cache::Contributable
  extend ActiveSupport::Autoload

  autoload :Persister
end