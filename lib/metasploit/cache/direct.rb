# Namespace for {Metasploit::Cache::Direct::Class class metadata} that is generated from a single
# {Metasploit::Cache::Direct::Class#ancestor ancestor's Metasploit Module}.
module Metasploit::Cache::Direct
  extend ActiveSupport::Autoload

  autoload :Class

  #
  # Module Methods
  #

  def self.table_name_prefix
    "#{parent.table_name_prefix}direct_"
  end
end