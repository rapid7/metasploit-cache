# Superclass for all `Metasploit::Cache::Payload::*::Class` that represent Metasploit Modules without a handler in their
# ancestors.
class Metasploit::Cache::Payload::Unhandled::Class < ActiveRecord::Base
  extend ActiveSupport::Autoload

  include Metasploit::Cache::Batch::Root
  include Metasploit::Cache::Module::Descendant

  autoload :AncestorCell
  autoload :Load

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

  #
  # Validations
  #

  validates :rank,
            presence: true
end