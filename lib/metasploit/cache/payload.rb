# Namespace for payload Metasploit Module cache metadata.  Payloads are further broken up by payload type:
# * {Metasploit::Cache::Payload::Single single}
module Metasploit::Cache::Payload
  extend ActiveSupport::Autoload

  autoload :Ancestor
  autoload :AncestorCell
  autoload :Direct
  autoload :Handable
  autoload :Handler
  autoload :Single
  autoload :Stage
  autoload :Staged
  autoload :Stager

  #
  # Module Methods
  #

  # The prefix for ActiveRecord::Base subclass table names in this namespace.
  #
  # @return [String]
  def self.table_name_prefix
    "#{parent.table_name_prefix}payload_"
  end
end