# Namespace for `ActiveRecord::Base` subclasses that support {Metasploit::Cache::Actionable::Action actions}.
module Metasploit::Cache::Actionable
  extend ActiveSupport::Autoload

  autoload :Action
end