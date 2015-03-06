# Superclass for all `Metasploit::Cache::*::Class` that have one {#ancestor}.
class Metasploit::Cache::Direct::Class < ActiveRecord::Base
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
  #   Reliability of Metasploit MOdule.
  #
  #   @return [Metasploit::Cache::Rank]

  #
  # Validations
  #

  validates :ancestor,
            presence: true
  validates :rank,
            presence: true
end