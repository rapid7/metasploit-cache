# Superclass for all `Metasploit::Cache::Payload::*::Class` that represent Metasploit Modules without a handler in their
# ancestors.
class Metasploit::Cache::Payload::Unhandled::Class < ActiveRecord::Base
  extend ActiveSupport::Autoload

  include Metasploit::Cache::Batch::Root

  autoload :AncestorCell
  autoload :Load

  #
  # Associations
  #

  # @!method ancestor
  #   @abstract Subclass and add the following association:
  #     ```ruby
  #       # Metadata for file that defined the ruby Class or Module.
  #       belongs_to :ancestor,
  #                  class_name: 'Metasploit::Cache::<module_typ>::Ancestor',
  #                  inverse_of: <association on Metasploit::Cache::<module_type>::Ancestor>
  #     ```
  #
  #   Metadata for file that defined the ruby Class or Module.
  #
  #   @return [Metasploit::Cache::Module::Ancestor]

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
  # Attributes
  #

  # @!method ancestor_id
  #   The primary key of the associated {#ancestor}.
  #
  #   @return [Integer]

  #
  # Validations
  #

  validates :ancestor,
            presence: true
  validates :ancestor_id,
            uniqueness: {
                unless: :batched?
            }
  validates :rank,
            presence: true
end