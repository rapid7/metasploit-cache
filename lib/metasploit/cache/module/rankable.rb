# Adds `#rank` validation on abstract `#rank` association
module Metasploit::Cache::Module::Rankable
  extend ActiveSupport::Concern

  included do
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
end