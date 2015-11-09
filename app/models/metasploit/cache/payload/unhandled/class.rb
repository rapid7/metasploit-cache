# Superclass for all `Metasploit::Cache::Payload::*::Class` that represent Metasploit Modules without a handler in their
# ancestors.
class Metasploit::Cache::Payload::Unhandled::Class < ActiveRecord::Base
  extend ActiveSupport::Autoload

  include Metasploit::Cache::Batch::Root
  include Metasploit::Cache::Module::Descendant
  include Metasploit::Cache::Module::Rankable

  autoload :AncestorCell
  autoload :Ephemeral
  autoload :Load
end