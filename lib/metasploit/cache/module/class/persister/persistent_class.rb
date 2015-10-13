# Adds a {#persistent_class} that is used to do the look up for {#persistent} in a Persister
module Metasploit::Cache::Module::Class::Persister::PersistentClass
  extend ActiveSupport::Concern

  included do
    #
    # Validations
    #

    validates :persistent_class,
              presence: true
  end

  #
  # Attributes
  #

  # The subclass of {Metasploit::Cache::Payload::Unhandled::Class} to use to look up {#persistent}.
  #
  # @return [Class<Metasploit::Cache::Payload::Unhandled::Class>]
  attr_accessor :persistent_class

  #
  # Instance Methods
  #

  protected

  # @return [ActiveRecord::Relation<>]
  def persistent_relation
    persistent_class.joins(
        :ancestor
    ).where(
        Metasploit::Cache::Module::Ancestor.arel_table[:real_path_sha1_hex_digest].eq(real_path_sha1_hex_digest)
    )
  end
end