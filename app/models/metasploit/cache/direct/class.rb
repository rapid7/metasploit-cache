# Superclass for all `Metasploit::Cache::*::Class` that have one {#ancestor}.
class Metasploit::Cache::Direct::Class < ActiveRecord::Base
  extend ActiveSupport::Autoload

  include Metasploit::Cache::Batch::Descendant
  include Metasploit::Cache::Batch::Root
  include Metasploit::Cache::Module::Class::Namable
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
  
  #
  # Instance Methods
  #

  # Derives reference name for Metasploit Module from {Metasploit::Cache::Module::Ancestor#relative_path}.
  #
  # @return [nil] if {#ancestor} is `nil` of {#ancestor}'s {Metasploit::Cache::Module::Ancestor#reference_name} is `nil`
  # @return [String] Relative path with type directory and file extension removed.
  def reference_name
    if ancestor
      Metasploit::Cache::Module::Class::Namable.reference_name relative_file_names: ancestor.relative_file_names,
                                                               scoping_levels: 1
    end
  end
end