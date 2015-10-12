# Abstract namespace for code shared between all `Metasploit::Cache::**::Class` models.
module Metasploit::Cache::Module::Class
  extend ActiveSupport::Autoload

  autoload :Persister
  autoload :Namable
  autoload :Name

  #
  # Module Methods
  #

  def self.table_name_prefix
    "#{parent.table_name_prefix}class_"
  end
end