# A `ActiveRecord::Base` subclass that has an `#ancestor` association to {Metasploit::Cache::Module::Ancestor}.
module Metasploit::Cache::Module::Descendant
  extend ActiveSupport::Concern

  included do
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
  end
end