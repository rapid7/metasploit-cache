# Polymorphic namespace for `ActiveRecord::Base` subclasses that support platforms.
module Metasploit::Cache::Platformable
  extend ActiveSupport::Autoload

  autoload :Persister
  autoload :Platform

  #
  # Module Methods
  #

  # The prefix for ActiveRecord::Base subclass table names in this namespace.
  #
  # @return [String]
  def self.table_name_prefix
    "#{parent.table_name_prefix}platformable_"
  end
end