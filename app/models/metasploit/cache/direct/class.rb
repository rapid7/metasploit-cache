# Superclass for all `Metasploit::Cache::*::Class` that have one {#ancestor}.
class Metasploit::Cache::Direct::Class < ActiveRecord::Base
  extend ActiveSupport::Autoload

  include Metasploit::Cache::Batch::Descendant
  include Metasploit::Cache::Batch::Root
  include Metasploit::Cache::Module::Descendant

  autoload :AncestorCell
  autoload :Ephemeral
  autoload :Framework
  autoload :Load
  autoload :Ranking
  autoload :Spec
  autoload :Superclass
  autoload :Usability

  #
  # Associations
  #

  # @!method rank
  #   @abstract Subclass and add the following association:
  #      ```ruby
  #        # Reliability of  Metasploit Module.
  #        belongs_to :rank,
  #                   class_name: 'Metasploit::Cache::Rank',
  #                   inverse_of: <association on Metasploit::Cache::Rank>
  #      ```
  #
  #   Reliability of Metasploit Module.
  #
  #   @return [Metasploit::Cache::Rank]

  validates :rank,
            presence: true
end