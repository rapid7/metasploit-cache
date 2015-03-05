# {Metasploit::Cache::Module::Instance#platforms Platforms} for {Metasploit::Cache::Module::Instance modules}.
class Metasploit::Cache::Platform < ActiveRecord::Base
  extend ActiveSupport::Autoload

  include Metasploit::Cache::Derivation
  include Metasploit::Model::Search
  include Metasploit::Model::Translation

  autoload :Seed

  #
  # Acts
  #

  acts_as_nested_set dependent: :destroy,
                     left_column: :left,
                     right_column: :right,
                     order: :fully_qualified_name

  #
  #
  # Associations
  #
  #

  # Joins this {Metasploit::Cache::Platform} to {Metasploit::Cache::Module::Instance modules} that support the platform.
  has_many :module_platforms, class_name: 'Metasploit::Cache::Module::Platform', dependent: :destroy, inverse_of: :platform

  # Joins this to {Metasploit::Cache::Module::Target targets} that support this platform.
  has_many :target_platforms, class_name: 'Metasploit::Cache::Module::Target::Platform', dependent: :destroy, inverse_of: :platform

  #
  # through: :module_platforms
  #

  # {Metasploit::Cache::Module::Instance Modules} that has this {Metasploit::Cache::Platform} as one of their supported
  # {Metasploit::Cache::Module::Instance#platforms platforms}.
  has_many :module_instances, class_name: 'Metasploit::Cache::Module::Instance', through: :module_platforms

  #
  # Attributes
  #

  # @!attribute fully_qualified_name
  #   The fully qualified name of this platform, as would be used in the platform list in a metasploit-framework
  #   module.
  #
  #   @return [String]

  # @!attribute parent
  #   The parent platform of this platform.  For example, Windows is parent of Windows 98, which is the parent of
  #   Windows 98 FE.
  #
  #   @return [nil] if this is a top-level platform, such as Windows or Linux.
  #   @return [Metasploit::Cache::Platform]

  # @!attribute relative_name
  #   The name of this platform relative to the {#fully_qualified_name} of {#parent}.
  #
  #   @return [String]

  #
  # Derivations
  #

  derives :fully_qualified_name, validate: true

  #
  # Mass Assignment Security
  #

  attr_accessible :relative_name

  #
  # Search
  #

  search_attribute :fully_qualified_name,
                   type: {
                       set: :string
                   }
  #
  # Validation
  #

  validates :fully_qualified_name,
            inclusion: {
                in: ->(record){
                  record.class.fully_qualified_name_set
                }
            }
  validates :relative_name,
            presence: true

  #
  # Class Methods
  #

  # List of valid {#fully_qualified_name} derived from {Metasploit::Cache::Platform::Seed::RELATIVE_NAME_TREE}.
  #
  # @return [Array<String>]
  def self.fully_qualified_name_set
    unless instance_variable_defined? :@fully_qualified_name_set
      @fully_qualified_name_set = Set.new

      self::Seed.each_attributes do |attributes|
        parent = attributes.fetch(:parent)
        relative_name = attributes.fetch(:relative_name)

        if parent
          fully_qualified_name = "#{parent} #{relative_name}"
        else
          fully_qualified_name = relative_name
        end

        @fully_qualified_name_set.add fully_qualified_name

        # yieldreturn
        fully_qualified_name
      end

      @fully_qualified_name_set.freeze
    end

    @fully_qualified_name_set
  end

  #
  # Instance Methods
  #

  # Derives {#fully_qualified_name} from {#parent}'s {#fully_qualified_name} and this platform's {#relative_name}.
  #
  # @return [nil] if {#relative_name} is blank.
  # @return [String] {#relative_name} if {#parent} is `nil`.
  # @return [String] '<{#parent} {#relative_name}> <{#relative_name}>' if {#parent} is not `nil`.
  def derived_fully_qualified_name
    if relative_name.present?
      if parent
        "#{parent.fully_qualified_name} #{relative_name}"
      else
        relative_name
      end
    end
  end

  # @!method fully_qualified_name=(fully_qualified_name)
  #   Sets {#fully_qualified_name}.
  #
  #   @param full_qualified_name [String] The fully qualified name of this platform, as would be used in the platform
  #     list in a metasploit-framework module.
  #   @return [void]

  # @!method module_platforms=(module_platforms)
  #   Sets {#module_platforms}.
  #
  #   @param module_platforms [Enumerable<Metasploit::Cache::Module::Platform>, nil] Joins this
  #     {Metasploit::Cache::Platform} to {Metasploit::Cache::Module::Instance modules} that support the platform.
  #   @return [void]

  # @!method parent=(parent)
  #   Sets {#parent}.
  #
  #   @param parent [Metasploit::Cache::Platform, nil]  The parent platform of this platform; `nil` if this is a
  #     top-level platform.
  #   @return [void]

  # @!method relative_name=(relative_name)
  #   Sets {#relative_name}.
  #
  #   @param relative_name [String] name of this platform relative to the {#fully_qualified_name} of {#parent}.
  #   @return [void]

  # @!method target_platforms=(target_platforms)
  #   Sets {#target_platforms}.
  #
  #   @param target_platforms [Enumerable<Metasploit::Cache::Target::Platform>, nil] Joins this to
  #     {Metasploit::Cache::Module::Target targets} that support this platform.
  #   @return [void]

  Metasploit::Concern.run(self)
end