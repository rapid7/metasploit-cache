# Name space to hold references join model
module Metasploit::Cache::Referencable
  extend ActiveSupport::Autoload

  autoload :Reference

  #
  # Module Methods
  #

  # The prefix for `ActiveRecord::Base` subclass table names in this namespace.
  #
  # @return [String]
  def self.table_name_prefix
    "#{parent.table_name_prefix}referencable_"
  end
end
