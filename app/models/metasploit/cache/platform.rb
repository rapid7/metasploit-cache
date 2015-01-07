# {Metasploit::Cache::Module::Instance#platforms Platforms} for {Metasploit::Cache::Module::Instance modules}.
class Metasploit::Cache::Platform < ActiveRecord::Base
  include Metasploit::Cache::Derivation
  include Metasploit::Model::Search
  include Metasploit::Model::Translation


  #
  # CONSTANTS
  #

  # Platforms are seeded in a hierarchy with deeper levels refining higher levels, so 'Windows 98 SE' is a
  # refinement of 'Windows 98', which is a refinement of 'Windows'.
  SEED_RELATIVE_NAME_TREE = {
      'AIX' => nil,
      'Android' => nil,
      'BSD' => nil,
      'BSDi' => nil,
      'Cisco' => nil,
      'Firefox' => nil,
      'FreeBSD' => nil,
      'HPUX' => nil,
      'IRIX' => nil,
      'Java' => nil,
      'Javascript' => nil,
      'Linux' => nil,
      'NetBSD' => nil,
      'Netware' => nil,
      'NodeJS' => nil,
      'OpenBSD' => nil,
      'OSX' => nil,
      'PHP' => nil,
      'Python' => nil,
      'Ruby' => nil,
      'Solaris' => {
          '4' => nil,
          '5' => nil,
          '6' => nil,
          '7' => nil,
          '8' => nil,
          '9' => nil,
          '10' => nil
      },
      'Windows' => {
          '95' => nil,
          '98' => {
              'FE' => nil,
              'SE' => nil
          },
          'ME' => nil,
          'NT' => {
              'SP0' => nil,
              'SP1' => nil,
              'SP2' => nil,
              'SP3' => nil,
              'SP4' => nil,
              'SP5' => nil,
              'SP6' => nil,
              'SP6a' => nil
          },
          '2000' => {
              'SP0' => nil,
              'SP1' => nil,
              'SP2' => nil,
              'SP3' => nil,
              'SP4' => nil
          },
          'XP' => {
              'SP0' => nil,
              'SP1' => nil,
              'SP2' => nil,
              'SP3' => nil
          },
          '2003' => {
              'SP0' => nil,
              'SP1' => nil
          },
          'Vista' => {
              'SP0' => nil,
              'SP1' => nil
          },
          '7' => nil
      },
      'UNIX' => nil
  }

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

  # @!attribute module_platforms
  #   Joins this {Metasploit::Cache::Platform} to {Metasploit::Cache::Module::Instance modules} that support the platform.
  #
  #   @return [ActiveRecord::Relation<Metasploit::Cache::Module::Platform>]
  has_many :module_platforms, class_name: 'Metasploit::Cache::Module::Platform', dependent: :destroy, inverse_of: :platform

  # @!attribute target_platforms
  #   Joins this to {Metasploit::Cache::Module::Target targets} that support this platform.
  #
  #   @return [ActiveRecord::Relation<Metasploit::Cache::Module::Target::Platform>]
  has_many :target_platforms, class_name: 'Metasploit::Cache::Module::Target::Platform', dependent: :destroy, inverse_of: :platform

  #
  # through: :module_platforms
  #

  # @!attribute [r] module_instance
  #   {Metasploit::Cache::Module::Instance Modules} that has this {Metasploit::Cache::Platform} as one of their supported
  #   {Metasploit::Cache::Module::Instance#platforms platforms}.
  #
  #   @return [ActiveRecord::Relation<Metasploit::Cache::Module::Instance>]
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

  # @param options [Hash{Symbol => Object, Hash}]
  # @option options [Object] :parent (nil) The parent object to which to attach the children.
  # @option options [Hash{String => nil,Hash}] :grandchildren_by_child_relative_name
  #   ({SEED_RELATIVE_NAME_TREE}) Maps {#relative_name} of children under :parent to their children
  #   (grandchildren of parent).  Grandchildren can be `nil` or another recursive `Hash` of names and their
  #   descendants.
  # @yield [attributes] Block should construct child object using attributes.
  # @yieldparam attributes [Hash{Symbol => Object,String}] Hash containing attributes for child object, include
  #   :parent for {#parent} and :relative_name for {#relative_name}.
  # @yieldreturn [Object] child derived from :parent and :relative_name to be used as the parent for
  #   grandchildren.
  # @return [void]
  def self.each_seed_attributes(options={}, &block)
    options.assert_valid_keys(:parent, :grandchildren_by_child_relative_name)

    parent = options[:parent]
    grandchildren_by_child_relative_name = options.fetch(
        :grandchildren_by_child_relative_name,
        SEED_RELATIVE_NAME_TREE
    )

    grandchildren_by_child_relative_name.each do |child_relative_name, great_grandchildren_by_grandchild_relative_name|
      attributes = {
          parent: parent,
          relative_name: child_relative_name
      }
      child = block.call(attributes)

      if great_grandchildren_by_grandchild_relative_name
        each_seed_attributes(
            grandchildren_by_child_relative_name: great_grandchildren_by_grandchild_relative_name,
            parent: child,
            &block
        )
      end
    end
  end

  # List of valid {#fully_qualified_name} derived from {SEED_RELATIVE_NAME_TREE}.
  #
  # @return [Array<String>]
  def self.fully_qualified_name_set
    unless instance_variable_defined? :@fully_qualified_name_set
      @fully_qualified_name_set = Set.new

      each_seed_attributes do |attributes|
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
  #   @param [String] The fully qualified name of this platform, as would be used in the platform list in a
  #     metasploit-framework module.
  #   @return [void]

  # @!method parent=(parent)
  #   Sets {#parent}.
  #
  #   @param [Metasploit::Cache::Platform, nil]  The parent platform of this platform; `nil` if this is a top-level
  #     platform.
  #   @return [void]

  # @!method relative_name=(relative_name)
  #   Sets {#relative_name}.
  #
  #   @param [String] the name of this platform relative to the {#fully_qualified_name} of {#parent}.
  #   @return [void]

  Metasploit::Concern.run(self)
end