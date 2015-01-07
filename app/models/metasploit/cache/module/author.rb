# Joins {Metasploit::Cache::Author} and {Metasploit::Cache::EmailAddress} to {Metasploit::Cache::Module::Instance} to record authors and the email they used for
# a given module.
class Metasploit::Cache::Module::Author < ActiveRecord::Base
  include Metasploit::Model::Translation
  include MetasploitDataModels::Batch::Descendant

  #
  # Associations
  #

  # @!attribute author
  #   Author who wrote the {#module_instance module}.
  #
  #   @return [Metasploit::Cache::Author]
  belongs_to :author, :class_name => 'Metasploit::Cache::Author', inverse_of: :module_authors

  # @!attribute email_address
  #   Email address {#author} used when writing {#module_instance module}.
  #
  #   @return [Metasploit::Cache::EmailAddress] if {#author} gave an email address.
  #   @return [nil] if {#author} only gave a name.
  belongs_to :email_address, class_name: 'Metasploit::Cache::EmailAddress', inverse_of: :module_authors

  # @!attribute module_instance
  #   Module written by {#author}.
  #
  #   @return [Metasploit::Cache::Module::Instance]
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

  #
  # Instance Methods
  #

  # @!method author=(author)
  #   Sets {#author}.
  #
  #   @param author [Metasploit::Cache::Author] Author who wrote the {#module_instanec module}.
  #   @return [void]

  # @!method email_address=(email_address)
  #   Sets {#email_address}.
  #
  #   @param email_address [Metasploit::Cache::EmailAddress] email address {#author} used when writing
  #     {#module_instance module}; `nil` if {#author} only gave a name.
  #   @return [void]

  # @!method module_instance=(module_instance)
  #   Sets {#module_instance}.
  #
  #   @param module_instance [Metasploit::Cache::Module::Instance] module written by {#author}.
  #   @return [void]

  Metasploit::Concern.run(self)
end
