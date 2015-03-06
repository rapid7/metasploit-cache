# Join model between {Metasploit::Cache::Module::Instance} and {Metasploit::Cache::Platform} used to represent a platform that a given module
# supports.
class Metasploit::Cache::Module::Platform < ActiveRecord::Base
  include Metasploit::Cache::Batch::Descendant
  include Metasploit::Model::Translation

  #
  # Associations
  #

  # Module that supports {#platform}.
  belongs_to :module_instance, class_name: 'Metasploit::Cache::Module::Instance', inverse_of: :module_platforms

  # Platform supported by {#module_instance}.
  belongs_to :platform, class_name: 'Metasploit::Cache::Platform', inverse_of: :module_platforms

  #
  # Attributes
  #

  # @!method platform_id
  #   The primary key of the associated {#platform}.
  #
  #   @return [Integer]

  #
  # Validations
  #

  validates :module_instance, presence: true
  validates :platform, presence: true
  validates :platform_id,
            uniqueness: {
                scope: :module_instance_id,
                unless: :batched?
            }

  #
  # Instance Methods
  #

  # @!method module_instance=(module_instance)
  #   Sets {#module_instance}.
  #
  #   @param module_instance [Metasploit::Cache::Module::Instance] Module that supports {#platform}.
  #   @return [void]

  # @!method platform=(platform)
  #   Sets {#platform}.
  #
  #   @param platform [Metasploit::Cache::Platform] platform supported by {#module_instance}.
  #   @return [void]

  Metasploit::Concern.run(self)
end
