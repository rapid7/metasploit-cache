# Joins {Metasploit::Cache::Author} and {Metasploit::Cache::EmailAddress} to {Metasploit::Cache::Module::Instance} to record authors and the email they used for
# a given module.
class Metasploit::Cache::Module::Author < ActiveRecord::Base
  include Metasploit::Cache::Batch::Descendant
  include Metasploit::Model::Translation

  #
  # Associations
  #

  # Author who wrote the {#module_instance module}.
  belongs_to :author, :class_name => 'Metasploit::Cache::Author', inverse_of: :module_authors

  # Email address {#author} used when writing {#module_instance module}.
  belongs_to :email_address, class_name: 'Metasploit::Cache::EmailAddress', inverse_of: :module_authors

  # Module written by {#author}.
  belongs_to :module_instance, class_name: 'Metasploit::Cache::Module::Instance', inverse_of: :module_authors

  #
  # Validations
  #

  validates :author,
            presence: true
  validates :author_id,
            uniqueness: {
                scope: :module_instance_id,
                unless: :batched?
            }
  validates :module_instance,
            presence: true

  Metasploit::Concern.run(self)
end
