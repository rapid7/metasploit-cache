# Code shared between `Mdm::Module::Author` and `Metasploit::Framework::Module::Author`.
module Metasploit::Cache::Module::Author
  extend ActiveModel::Naming
  extend ActiveSupport::Concern

  include Metasploit::Model::Translation

  included do
    include ActiveModel::Validations

    #
    # Validations
    #

    validates :author,
              :presence => true
    validates :module_instance,
              :presence => true
  end

  #
  # Associations
  #

  # @!attribute author
  #   Author who wrote the {#module_instance module}.
  #
  #   @return [Metasploit::Cache::Author]

  # @!attribute email_address
  #   Email address {#author} used when writing {#module_instance module}.
  #
  #   @return [Metasploit::Cache::EmailAddress] if {#author} gave an email address.
  #   @return [nil] if {#author} only gave a name.

  # @!attribute module_instance
  #   Module written by {#author}.
  #
  #   @return [Metasploit::Cache::Module::Instance]

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
  #   @param email_address [Metapsloit::Cache::EmailAddress] email address {#author} used when writing
  #     {#module_instance module}; `nil` if {#author} only gave a name.
  #   @return [void]

  # @!method module_instance=(module_instance)
  #   Sets {#module_instance}.
  #
  #   @param module_instance [Metasploit::Cache::Module::Instance] module written by {#author}.
  #   @return [void]
end
