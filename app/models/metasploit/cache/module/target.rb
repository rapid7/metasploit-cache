# A potential target for a {Metasploit::Cache::Module::Instance module}.  Targets can change options including offsets for ROP chains
# to tune an exploit to work with different system libraries and versions.
class Metasploit::Cache::Module::Target < ActiveRecord::Base
  extend ActiveSupport::Autoload

  include Metasploit::Cache::Batch::Descendant
  include Metasploit::Model::Search
  include Metasploit::Model::Translation

  autoload :Architecture
  autoload :Platform

  #
  #
  # Associations
  #
  #

  # Module where this target was declared.
  belongs_to :module_instance, class_name: 'Metasploit::Cache::Module::Instance', inverse_of: :targets

  # Joins this target to its {#architectures}
  has_many :target_architectures,
           class_name: 'Metasploit::Cache::Module::Target::Architecture',
           dependent: :destroy,
           foreign_key: :module_target_id,
           inverse_of: :module_target

  # Joins this target to its {#platforms}
  has_many :target_platforms,
           class_name: 'Metasploit::Cache::Module::Target::Platform',
           dependent: :destroy,
           foreign_key: :module_target_id,
           inverse_of: :module_target

  #
  # through: :target_architectures
  #

  # Architectures that this target supports, either by being declared specifically for this target or because this
  # target did not override architectures and so inheritted the architecture set from the class.
  has_many :architectures, class_name: 'Metasploit::Cache::Architecture', through: :target_architectures

  #
  # through: :target_platforms
  #

  # Platforms that this target supports, either by being declared specifically for this target or because this target
  # did not override platforms and so inheritted the platform set from the class.
  has_many :platforms, class_name: 'Metasploit::Cache::Platform', through: :target_platforms

  #
  # Attributes
  #

  # @!attribute name
  #   The name of this target.
  #
  #   @return [String]

  #
  # Mass Assignment Security
  #

  attr_accessible :index
  attr_accessible :name

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
  validates :target_architectures, presence: true
  validates :target_platforms, presence: true

  #
  # Search Attributes
  #

  search_attribute :name,
                   type: :string

  #
  # Instance Methods
  #

  # @!method module_instance=(module_instance)
  #   Sets {#module_instance}.
  #
  #   @param module_instance [Metasploit::Cache::Module::Instance] module where this target was declared.
  #   @return [void]

  # @!method name=(name)
  #   Sets {#name}.
  #
  #   @param name [String] name of this target.
  #   @return [void]

  # @!method target_architectures=(target_architectures)
  #   Sets {#target_architectures}.
  #
  #   @param target_architectures [Array<Metasploit::Cache::Module::Target::Architecture>] joins this target ot its
  #     {#architectures}.
  #   @return [void]

  # @!method target_platforms=(target_platforms)
  #   Sets {#target_platforms}.
  #
  #   @param target_platforms [Array<Metasploit::Cache::Module::Target::Platform>] joins this target to its
  #     {#platforms}.
  #   @return [void]

  Metasploit::Concern.run(self)
end
