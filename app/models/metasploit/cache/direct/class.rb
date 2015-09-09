# Superclass for all `Metasploit::Cache::*::Class` that have one {#ancestor}.
class Metasploit::Cache::Direct::Class < ActiveRecord::Base
  extend ActiveSupport::Autoload

  include Metasploit::Cache::Batch::Descendant
  include Metasploit::Cache::Batch::Root
  include Metasploit::Cache::Module::Descendant
  include Metasploit::Cache::Module::Rankable

  autoload :AncestorCell
  autoload :Ephemeral
  autoload :Framework
  autoload :Load
  autoload :Ranking
  autoload :Spec
  autoload :Superclass
  autoload :Usability
end