# Polymorphic namespace for `ActiveRecord::Base` subclasses that support platforms.
module Metasploit::Cache::Platformable
  extend ActiveSupport::Autoload

  autoload :Platform
end