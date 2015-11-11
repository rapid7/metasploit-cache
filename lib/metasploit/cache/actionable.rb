# Namespace for `ActiveRecord::Base` subclasses that support {Metasploit::Cache::Actionable::Action actions}.
module Metasploit::Cache::Actionable
  extend ActiveSupport::Autoload

  autoload :Action
  autoload :Persister

  #
  # Module Methods
  #

  # The prefix for ActiveRecord::Base subclass table names in this namespace.
  #
  # @return [String]
  def self.table_name_prefix
    "#{parent.table_name_prefix}actionable_"
  end
end