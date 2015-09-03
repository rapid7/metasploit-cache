# Namespace for {Metasploit::Cache::Payload::Handled::Class class metadata} that is generated from one payload
# {Metasploit::Cache::Direct::Class#ancestor ancestor's Metasploit Module} and the handler module from the
# {Metasploit::Cache::Payload::Single::Unhandled::Instance}.
module Metasploit::Cache::Payload::Single::Handled
  extend ActiveSupport::Autoload

  autoload :Class

  #
  # Module Methods
  #

  # The prefix for ActiveRecord::Base subclass table names in this namespace.
  #
  # @return [String]
  def self.table_name_prefix
    "#{parent.table_name_prefix}handled_"
  end
end