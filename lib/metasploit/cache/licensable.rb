# Namespace to hold license join model
module Metasploit::Cache::Licensable
  extend ActiveSupport::Autoload

  autoload :License

  #
  # Module Methods
  #

  # The prefix for `ActiveRecord::Base` subclass table names in this namespace.
  #
  # @return [String]
  def self.table_name_prefix
    "#{parent.table_name_prefix}licensable_"
  end
end
