# Namespace for nop Metasploit Module cache metadata, including from
# {Metasploit::Cache::Nop::Ancestor ancestors}, {Metasploit::Cache::Nop::Class classes}, and
# {Metasploit::Cache::Nop::Instance instances}.
module Metasploit::Cache::Nop
  extend ActiveSupport::Autoload

  autoload :Ancestor
  autoload :Class
  autoload :Instance

  #
  # Module Methods
  #

  # The prefix for `ActiveRecord::Base` subclass table names in this namespace.
  #
  # @return [String]
  def self.table_name_prefix
    "#{parent.table_name_prefix}nop_"
  end
end