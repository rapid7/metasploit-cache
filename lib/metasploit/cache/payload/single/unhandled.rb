# Namespace for single payload Metasploit Module class that does not have the handler mixed in.
module Metasploit::Cache::Payload::Single::Unhandled
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