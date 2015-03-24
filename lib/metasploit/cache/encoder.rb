# Namespace for encoder Metasploit Module cache metadata, including from
# {Metasploit::Cache::Encoder::Ancestor ancestors}, {Metasploit::Cache::Encoder::Class classes}, and
# {Metasploit::Cache::Encoder::Instance instnaces}.
module Metasploit::Cache::Encoder
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
    "#{parent.table_name_prefix}encoder_"
  end
end