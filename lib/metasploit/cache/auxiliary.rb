# Namespace for auxiliary Metasploit Module cache metadata, including from
# {Metasploit::Cache::Auxiliary::Ancestor ancestors}, {Metasploit::Cache::Auxiliary::Class classes}, and
# {Metasploit::Cache::Auxiliary::Instance instances}.
module Metasploit::Cache::Auxiliary
  extend ActiveSupport::Autoload

  autoload :Ancestor
  autoload :Class
  autoload :Instance


  #
  # Module Methods
  #

  # The prefix for ActiveRecord::Base subclass table names in this namespace.
  #
  # @return [String]
  def self.table_name_prefix
    "#{parent.table_name_prefix}auxiliary_"
  end
end