# Polymorphic namespace for `ActiveRecord::Base` subclasses that support architectures.
module Metasploit::Cache::Architecturable
  extend ActiveSupport::Autoload

  autoload :Architecture
end