# Namespace for post Metasploit Module cache metadata, including from
# {Metasploit::Cache::Post::Ancestor ancestors}, {Metasploit::Cache::Post::Class classes}, and
# {Metasploit::Cache::Post::Instance instances}.
module Metasploit::Cache::Post
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
    "#{parent.table_name_prefix}post_"
  end
end