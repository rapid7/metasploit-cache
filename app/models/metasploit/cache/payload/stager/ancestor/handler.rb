# Handler aliasing supported by stager payload Metasploit Module ruby Modules through `handler_type_alias` Module
# method.
class Metasploit::Cache::Payload::Stager::Ancestor::Handler < ActiveRecord::Base
  include Metasploit::Cache::Batch::Descendant

  self.table_name = :mc_payload_stager_ancestor_handlers

  #
  # Associations
  #

  belongs_to :payload_stager_ancestor,
             class_name: 'Metasploit::Cache::Payload::Stager::Ancestor',
             foreign_key: :payload_stager_ancestor_id,
             inverse_of: :handler

  #
  # Attributes
  #

  # @!attribute type_alias
  #   @note Should never be `nil`.  If the Metasploit Module ruby Module does not respond to `handler_type_alias`, then
  #     {Metasploit::Cache::Payload::Stager::Ancestor#handler} should be `nil`.
  #
  #   Value returned from `handler_type_alias` Module method from Metasploit Module ruby Module.
  #
  #   @return [String]

  #
  # Validations
  #

  validates :payload_stager_ancestor,
            presence: true
  validates :payload_stager_ancestor_id,
            uniqueness: {
                unless: :batched?
            }
  validates :type_alias,
            presence: true

  Metasploit::Concern.run(self)
end