# A potential target for a {Metasploit::Cache::Module::Instance module}.  Targets can change options including offsets for ROP chains
# to tune an exploit to work with different system libraries and versions.
class Metasploit::Cache::Module::Target < ActiveRecord::Base
  include Metasploit::Cache::Batch::Descendant
  include Metasploit::Model::Search
  include Metasploit::Model::Translation

  #
  #
  # Associations
  #
  #

  # Module where this target was declared.
  belongs_to :module_instance, class_name: 'Metasploit::Cache::Module::Instance', inverse_of: :targets

  #
  # Attributes
  #

  # @!attribute name
  #   The name of this target.
  #
  #   @return [String]

  #
  # Validations
  #

  validates :module_instance,
            presence: true
  validates :name,
            presence: true,
            uniqueness: {
                scope: :module_instance_id,
                unless: :batched?
            }

  #
  # Search Attributes
  #

  search_attribute :name,
                   type: :string

  Metasploit::Concern.run(self)
end
