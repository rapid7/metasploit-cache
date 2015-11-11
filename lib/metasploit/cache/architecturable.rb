# Polymorphic namespace for `ActiveRecord::Base` subclasses that support architectures.
module Metasploit::Cache::Architecturable
  extend ActiveSupport::Autoload

  autoload :Architecture
  autoload :Persister

  #
  # Module Methods
  #

  # The prefix for ActiveRecord::Base subclass table names in this namespace.
  #
  # @return [String]
  def self.table_name_prefix
    "#{parent.table_name_prefix}architecturable_"
  end
end