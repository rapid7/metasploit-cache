# Namespace for {Metasploit::Cache::Payload::Direct::Class class metadata} that is generated from one payload
# {Metasploit::Cache::Payload::Direct::Class#ancestor ancestor's Metasploit Module}.
module Metasploit::Cache::Payload::Direct
  extend ActiveSupport::Autoload

  autoload :Class

  #
  # Module Methods
  #

  def self.table_name_prefix
    "#{parent.table_name_prefix}direct_"
  end
end