# Namespace for single payload Metasploit Module cache metadata, including
# {Metasploit::Cache::Payload::Single::Ancestor ancestors}, {Metasploit::Cache::Payload::Single::Unhandled::Class classes},
# {Metasploit::Cache::Payload::Single::Instance instances}.
module Metasploit::Cache::Payload::Single
  extend ActiveSupport::Autoload

  autoload :Ancestor
  autoload :Unhandled
  autoload :Instance

  #
  # Module Methods
  #

  # The prefix for ActiveRecord::Base subclass table names in this namespace.
  #
  # @return [String]
  def self.table_name_prefix
    "#{parent.table_name_prefix}single_"
  end
end