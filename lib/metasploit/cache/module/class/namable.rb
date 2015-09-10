# Add `#name` association to an `ActiveRecord::Base` subclass.
module Metasploit::Cache::Module::Class::Namable
  extend ActiveSupport::Concern

  included do
    #
    # Associations
    #

    has_one :name,
            as: :module_class,
            class_name: 'Metasploit::Cache::Module::Class::Name',
            dependent: :destroy,
            foreign_key: :module_class_id,
            inverse_of: :module_class

    #
    # Validations
    #

    validates :name,
              presence: true
  end
end