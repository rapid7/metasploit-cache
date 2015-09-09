# Namespace for {Metasploit::Cache::Payload::Unhandled::Class class metadata} that is generated from one payload
# {Metasploit::Cache::Direct::Class#ancestor ancestor's Metasploit Module}.
module Metasploit::Cache::Payload::Unhandled
  extend ActiveSupport::Autoload

  autoload :Class
  autoload :Instance

  #
  # Module Methods
  #

  # The prefix for ActiveRecord::Base subclass table names in this namespace.
  #
  # @return [String]
  def self.table_name_prefix
    "#{parent.table_name_prefix}unhandled_"
  end
end