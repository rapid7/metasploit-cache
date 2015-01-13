# Details about an Msf::Module.  Metadata that can be an array is stored in associations in modules under the
# {Metasploit::Cache::Module} namespace.
class Metasploit::Cache::Module::Instance < ActiveRecord::Base
  extend ActiveSupport::Autoload

  include Metasploit::Cache::Batch::Root
  include Metasploit::Model::Search
  include Metasploit::Model::Translation

  autoload :Spec

  #
  # CONSTANTS
  #

  # {#dynamic_length_validation_options} by {#module_type} by attribute.
  DYNAMIC_LENGTH_VALIDATION_OPTIONS_BY_MODULE_TYPE_BY_ATTRIBUTE = {
      actions: {
          Metasploit::Cache::Module::Type::AUX => {
              minimum: 0
          },
          Metasploit::Cache::Module::Type::ENCODER => {
              is: 0
          },
          Metasploit::Cache::Module::Type::EXPLOIT => {
              is: 0
          },
          Metasploit::Cache::Module::Type::NOP => {
              is: 0
          },
          Metasploit::Cache::Module::Type::PAYLOAD => {
              is: 0
          },
          Metasploit::Cache::Module::Type::POST => {
              minimum: 0
          }
      },
      module_architectures: {
          Metasploit::Cache::Module::Type::AUX => {
              is: 0
          },
          Metasploit::Cache::Module::Type::ENCODER => {
              minimum: 1
          },
          Metasploit::Cache::Module::Type::EXPLOIT => {
              minimum: 1
          },
          Metasploit::Cache::Module::Type::NOP => {
              minimum: 1
          },
          Metasploit::Cache::Module::Type::PAYLOAD => {
              minimum: 1
          },
          Metasploit::Cache::Module::Type::POST => {
              minimum: 1
          }
      },
      module_platforms: {
          Metasploit::Cache::Module::Type::AUX => {
              is: 0
          },
          Metasploit::Cache::Module::Type::ENCODER => {
              is: 0
          },
          Metasploit::Cache::Module::Type::EXPLOIT => {
              minimum: 1
          },
          Metasploit::Cache::Module::Type::NOP => {
              is: 0
          },
          Metasploit::Cache::Module::Type::PAYLOAD => {
              minimum: 1
          },
          Metasploit::Cache::Module::Type::POST => {
              minimum: 1
          }
      },
      module_references: {
          Metasploit::Cache::Module::Type::AUX => {
              minimum: 0
          },
          Metasploit::Cache::Module::Type::ENCODER => {
              is: 0
          },
          Metasploit::Cache::Module::Type::EXPLOIT => {
              minimum: 1
          },
          Metasploit::Cache::Module::Type::NOP => {
              is: 0
          },
          Metasploit::Cache::Module::Type::PAYLOAD => {
              is: 0
          },
          Metasploit::Cache::Module::Type::POST => {
              minimum: 0
          }
      },
      targets: {
          Metasploit::Cache::Module::Type::AUX => {
              is: 0
          },
          Metasploit::Cache::Module::Type::ENCODER => {
              is: 0
          },
          Metasploit::Cache::Module::Type::EXPLOIT => {
              minimum: 1
          },
          Metasploit::Cache::Module::Type::NOP => {
              is: 0
          },
          Metasploit::Cache::Module::Type::PAYLOAD => {
              is: 0
          },
          Metasploit::Cache::Module::Type::POST => {
              is: 0
          }
      }
  }

  # Minimum length of {#module_authors}.
  MINIMUM_MODULE_AUTHORS_LENGTH = 1

  # {#privileged} is Boolean so, valid values are just `true` and `false`, but since both the validation and
  # factory need an array of valid values, this constant exists.
  PRIVILEGES = [
      false,
      true
  ]

  # Member of {Metasploit::Cache::Module::Type::ALL} that require {#stance} to be non-`nil`.
  STANCED_MODULE_TYPES = [
      Metasploit::Cache::Module::Type::AUX,
      Metasploit::Cache::Module::Type::EXPLOIT
  ]

  #
  #
  # Associations
  #
  #

  # @!attribute actions
  #   Auxiliary actions to perform when this running this module.
  #
  #   @return [ActiveRecord::Relation<Metasploit::Cache::Module::Action>]
  has_many :actions,
           class_name: 'Metasploit::Cache::Module::Action',
           dependent: :destroy,
           foreign_key: :module_instance_id,
           inverse_of: :module_instance

  # @!attribute default_action
  #   The default action in {#actions}.
  #
  #   @return [Metasploit::Cache::Module::Action]
  belongs_to :default_action, class_name: 'Metasploit::Cache::Module::Action', inverse_of: :module_instance

  # @!attribute default_target
  #   The default target in {#targets}.
  #
  #   @return [Metasploit::Cache::Module::Target]
  belongs_to :default_target, class_name: 'Metasploit::Cache::Module::Target', inverse_of: :module_instance

  # @!attribute module_architectures
  #   Joins this {Metasploit::Cache::Module::Instance} to its supported {Metasploit::Cache::Architecture architectures}.
  #
  #   @return [ActiveRecord::Relation<Metasploit::Cache::Module::Architecture>]
  has_many :module_architectures,
           class_name: 'Metasploit::Cache::Module::Architecture',
           dependent: :destroy,
           foreign_key: :module_instance_id,
           inverse_of: :module_instance

  # @!attribute module_authors
  #   Joins this with {#authors} and {#email_addresses} to model the name and email address used for an author entry in
  #   the module metadata.
  #
  #   @return [ActiveRecord::Relation<Metasploit::Cache::Module::Author>]
  has_many :module_authors,
           class_name: 'Metasploit::Cache::Module::Author',
           dependent: :destroy,
           foreign_key: :module_instance_id,
           inverse_of: :module_instance

  # @!attribute module_class
  #   Class-derived metadata to go along with the instance-derived metadata in this model.
  #
  #   @return [Metasploit::Cache::Module::Class]
  belongs_to :module_class, class_name: 'Metasploit::Cache::Module::Class', inverse_of: :module_instance

  # @!attribute module_platforms
  #   Joins this {Metasploit::Cache::Module::Instance} to its supported {Metasploit::Cache::Platform platforms}.
  #
  #   @return [ActiveRecord::Relation<Metasploit::Cache::Module::Platform>]
  has_many :module_platforms,
           class_name: 'Metasploit::Cache::Module::Platform',
           dependent: :destroy,
           foreign_key: :module_instance_id,
           inverse_of: :module_instance

  # @!attribute module_references
  #   Joins {#references} to this {Metasploit::Cache::Module::Instance}.
  #
  #   @return [ActiveRecord::Relation<Metasploit::Cache::Module::Reference>]
  has_many :module_references,
           class_name: 'Metasploit::Cache::Module::Reference',
           dependent: :destroy,
           foreign_key: :module_instance_id,
           inverse_of: :module_instance

  # @!attribute targets
  #   Names of targets with different configurations that can be exploited by this module.
  #
  #   @return [ActiveRecord::Relation<Metasploit::Cache::Module::Target>]
  has_many :targets,
           class_name: 'Metasploit::Cache::Module::Target',
           dependent: :destroy,
           foreign_key: :module_instance_id,
           inverse_of: :module_instance

  #
  # through: :module_architectures
  #

  # @!attribute [r] architectures
  #   The {Metasploit::Cache::Module::Architecture architectures} supported by this module.
  #
  #   @return [ActiveRecord::Relation<Metasploit::Cache::Architecture>]
  has_many :architectures, :class_name => 'Metasploit::Cache::Architecture', :through => :module_architectures

  #
  # through: :module_authors
  #

  # @!attribute [r] authors
  #   The names of the authors of this module.
  #
  #   @return [ActiveRecord::Relation<Metasploit::Cache::Author>]
  has_many :authors, :class_name => 'Metasploit::Cache::Author', :through => :module_authors

  # @!attribute [r] email_addresses
  #   The email addresses of the authors of this module.
  #
  #   @return [ActiveRecord::Relation<Metasploit::Cache::EmailAddress>]
  has_many :email_addresses, :class_name => 'Metasploit::Cache::EmailAddress', :through => :module_authors, :uniq => true

  #
  # through: :module_class
  #

  # @!attribute [r] rank
  #   The rank of this module.
  #
  #   @return [Metasploit::Cache::Module::Rank]
  has_one :rank, :class_name => 'Metasploit::Cache::Module::Rank', :through => :module_class

  #
  # through: :module_platforms
  #

  # @!attribute [r] platforms
  #   Platforms supported by this module.
  #
  #   @return [ActiveRecord::Relation<Metasploit::Cache::Module::Platform>]
  has_many :platforms, :class_name => 'Metasploit::Cache::Platform', :through => :module_platforms

  #
  # through: :module_references
  #

  # @!attribute [r] references
  #   External references to the exploit or proof-of-concept (PoC) code in this module.
  #
  #   @return [ActiveRecord::Relation<Metasploit::Cache::Reference>]
  has_many :references, :class_name => 'Metasploit::Cache::Reference', :through => :module_references

  #
  # through: :references
  #

  # @!attribute [r] authorities
  #   Authorities across all {#references} to this module.
  #
  #   @return [ActiveRecord<Metasploit::Cache::Authority>]
  has_many :authorities, :class_name => 'Metasploit::Cache::Authority', :through => :references, :uniq => true

  #
  # Attributes
  #

  # @!attribute description
  #   A long, paragraph description of what the module does.
  #
  #   @return [String]

  # @!attribute disclosed_on
  #   The date the vulnerability exploited by this module was disclosed to the public.
  #
  #   @return [Date, nil]

  # @!attribute license
  #   The name of the software license for the module's code.
  #
  #   @return [String]

  # @!attribute name
  #   The human readable name of the module.  It is unrelated to {Metasploit::Cache::Module::Class#full_name} or
  #   {Metasploit::Cache::Module::Class#reference_name} and is better thought of as a short summary of the {#description}.
  #
  #   @return [String]

  # @!attribute privileged
  #   Whether this module requires privileged access to run.
  #
  #   @return [Boolean]

  # @!attribute stance
  #   Whether the module is active or passive.  `nil` if the {Metasploit::Cache::Module::Class#module_type module type} does not
  #   support stances.
  #
  #   @return ['active', 'passive', nil]
  #   @see Metasploit::Cache::Module::Instance#supports_stance?

  #
  # Scopes
  #

  # @!method self.compatible_privilege_with(module_instance)
  #   List of {Metasploit::Cache::Module::Instance Metasploit::Cache::Module::Instances} that are unprivileged if `module_instance` {#privileged} is
  #   `false` or all {Metasploit::Cache::Module::Instance Metasploit::Cache::Module::Instances} if `module_instance` {#privileged} is `true` because
  #   a privileged payload can only run if the exploit gives it privileged access.
  #
  #   @return [ActiveRecord::Relation<Metasploit::Cache::Module::Instance>]
  scope :compatible_privilege_with,
        ->(module_instance){
          unless module_instance.privileged?
            where(privileged: false)
          end
        }

  # @!method self.encoders_compatible_with(module_instance)
  #   {Metasploit::Cache::Module::Instance Metasploit::Cache::Module::Instances} that share at least 1 {Metasploit::Cache::Architecture} with the given
  #   `module_instance`'s {Metasploit::Cache::Module::Instance#archtiectures} and have {#module_class}
  #   {Metasploit::Cache::Module::Class#module_type} of `'encoder'`.
  #
  #   @param module_instance [Metasploit::Cache::Module::Instance] module instance whose {Metasploit::Cache::Module::Instance#architectures} need to
  #     have at least 1 {Metasploit::Cache::Architecture} shared with the returned {Metasploit::Cache::Module::Instance Metasploit::Cache::Module::Instances'}
  #     {Metasploit::Cache::Module::instance#architectures}.
  #   @return [ActiveRecord::Relation<Metasploit::Cache::Module::Instance>]
  scope :encoders_compatible_with,
        ->(module_instance){
          with_module_type(
              'encoder'
          ).intersecting_architectures_with(
              module_instance
          ).select(
              Metasploit::Cache::Module::Instance.arel_table['*']
          ).select(
              Metasploit::Cache::Module::Rank.arel_table[:number]
          ).uniq.ranked
        }

  # @!method self.intersecting_architecture_abbreviations
  #   List of {Metasploit::Cache::Module::Instance Metasploit::Cache::Module::Instances} that share at least 1 {Metasploit::Cache::Architecture#abbreviation} with
  #   the given `architecture_abbreviations`.
  #
  #   @param architecture_abbreviations [Array<String>]
  #   @return [ActiveRecord::Relation<Metasploit::Cache::Module::Instance>]
  scope :intersecting_architecture_abbreviations,
        ->(architecture_abbreviations){
          joins(
              :architectures
          ).where(
              Metasploit::Cache::Architecture.arel_table[:abbreviation].in(architecture_abbreviations)
          )
        }

  # @!method self.intersecting_platforms_with(architectured)
  #   List of {Metasploit::Cache::Module::Instance Metasploit::Cache::Module::Instances} that share at least 1 {Metasploit::Cache::Architecture} with the given
  #   architectured record's `#architectures`.
  #
  #   @param architectured [Metasploit::Cache::Module::Instance, Metasploit::Cache::Module::Target, #architectures] target whose `#architectures`
  #     need to have at least 1 {Metasploit::Cache::Architecture} shared with the returned
  #     {Metasploit::Cache::Module::Instance Metasploit::Cache::Module::Instances'} {Metasploit::Cache::Module::Instance#architectures}.
  #   @return [ActiveRecord::Relation<Metasploit::Cache::Module::Instance>]
  scope :intersecting_architectures_with,
        ->(architectured){
          intersecting_architecture_abbreviations(
              architectured.architectures.select(:abbreviation).build_arel
          )
        }

  # @!method self.intersecting_platforms(platforms)
  #   List of {Metasploit::Cache::Module::Instance Metasploit::Cache::Module::Instances} that has at least 1 {Metasploit::Cache::Platform} from `platforms`.
  #
  #   @param platforms [Enumerable<Metasploit::Cache::Platform>, #collect] list of {Metasploit::Cache::Platform Metasploit::Cache::Platforms} need to themselves
  #     or their descendants shared with the returned {Metasploit::Cache::Module::Instance Metasploit::Cache::Module::Instances'}
  #     {Metasploit::Cache::Module::Instance#platforms}.
  #   @return [ActiveRecord::Relation<Metasploit::Cache::Module::Instance>]
  scope :intersecting_platforms,
        ->(platforms){
          platforms_arel_table = Metasploit::Cache::Platform.arel_table
          platforms_left = platforms_arel_table[:left]
          platforms_right = platforms_arel_table[:right]

          platform_intersection_conditions = platforms.collect { |platform|
            platform_left = platform.left
            platform_right = platform.right

            # the payload's platform is an ancestor or equal to the target `platform`
            platforms_left.lteq(platform_left).and(
                platforms_right.gteq(platform_right)
            ).or(
                # the payload's platform is a descendant or equal to the target 'platform``
                platforms_left.gteq(platform_left).and(
                    platforms_right.lteq(platform_right)
                )
            )
          }
          platform_intersection_union = platform_intersection_conditions.reduce(:or)

          joins(
              :platforms
          ).where(
              platform_intersection_union
          )
        }

  # @!method self.intersecting_platform_fully_qualified_names(platform_fully_qualified_names)
  #   List of {Metasploit::Cache::Module::Instance Metasploit::Cache::Module::Instances} that has at least 1 {Metasploit::Cache::Platform}
  #   that either has a {Metasploit::Cache::Platform#fully_qualified_name} from `platform_fully_qualified_names` or that has an
  #   descendant with a {Metasploit::Cache::Platform#fully_qualified_name} from `platform_fully_qualified_names`.
  #
  #   @param platform_fully_qualified_names [Array<String>] `Array` of {Metasploit::Cache::Platform#fully_qualified_name}.
  #   @return [ActiveRecord::Relation<Metasploit::Cache::Module::Instance>]
  scope :intersecting_platform_fully_qualified_names,
        ->(platform_fully_qualified_names){
          intersecting_platforms(
              Metasploit::Cache::Platform.where(
                  fully_qualified_name: platform_fully_qualified_names
              )
          )
        }

  # @!method self.intersecting_platforms_with(module_target)
  #   List of {Metasploit::Cache::Module::Instance Metasploit::Cache::Module::Instances} that share at least 1 {Metasploit::Cache::Platform} or descendant with
  #   the given `module_target`'s {Metasploit::Cache::Module::Target#platforms}.
  #
  #   @param module_target [Metasploit::Cache::Module::Target] target whose {Metasploit::Cache::Module::Target#platforms} need to have at least 1
  #     {Metasploit::Cache::Platform} or its descendants shared with the returned {Metasploit::Cache::Module::Instance Metasploit::Cache::Module::Instances'}
  #     {Metasploit::Cache::Module::Instance#platforms}.
  #   @return [ActiveRecord::Relation<Metasploit::Cache::Module::Instance>]
  scope :intersecting_platforms_with,
        ->(module_target){
          intersecting_platforms(module_target.platforms)
        }

  # @!method self.nops_compatible_with(module_instance)
  #   {Metasploit::Cache::Module::Instance Metasploit::Cache::Module::Instances} that share at least 1 {Metasploit::Cache::Architecture} with the given
  #   `module_instance`'s {Metasploit::Cache::Module::Instance#archtiectures} and have {#module_class}
  #   {Metasploit::Cache::Module::Class#module_type} of `'nop'`.
  #
  #   @param module_instance [Metasploit::Cache::Module::Instance] module instance whose {Metasploit::Cache::Module::Instance#architectures} need to
  #     have at least 1 {Metasploit::Cache::Architecture} shared with the returned {Metasploit::Cache::Module::Instance Metasploit::Cache::Module::Instances'}
  #     {Metasploit::Cache::Module::instance#architectures}.
  #   @return [ActiveRecord::Relation<Metasploit::Cache::Module::Instance>]
  scope :nops_compatible_with,
        ->(module_instance){
          with_module_type(
              'nop'
          ).intersecting_architectures_with(
              module_instance
          ).ranked
        }

  # @!method self.ranked
  #   Orders {Metasploit::Cache::Module::Instance Metasploit::Cache::Module::Instances} by their {#module_class} {Metasploit::Cache::Module::Class#rank}
  #   {Metasploit::Cache::Module::Rank#number} in descending order so better, more reliable modules are first.
  #
  #   @return [ActiveRecord::Relation<Metasploit::Cache::Module::Instance>]
  #   @see Metasploit::Cache::Module::Class.ranked
  scope :ranked,
        ->{
          joins(
              module_class: :rank
          ).order(
              Metasploit::Cache::Module::Rank.arel_table[:number].desc
          )
        }


  # @!method self.with_module_type(module_type)
  #   {Metasploit::Cache::Module::Instance} that have {#module_class} {Metasploit::Cache::Module::Class#module_type} of `module_type`.
  #
  #   @return [ActiveRecord::Relation<Metasploit::Cache::Module::Instance>]
  scope :with_module_type,
        ->(module_type){
          joins(
              :module_class
          ).where(
              Metasploit::Cache::Module::Class.arel_table[:module_type].eq(module_type)
          )
        }

  # @!method self.payloads_compatible_with(module_target)
  #   @note In addition to the compatibility checks down using the module cache: (1) the actual `Msf::Payload`
  #     referenced by the {Metasploit::Cache::Module::Instance} must be checked that it's `Msf::Payload#size` fits the size
  #     restrictions of the `Msf::Exploit#payload_space`; and (2) the compatibility checks performed by
  #     `Msf::Module#compatible?` all pass.
  #
  #   {Metasploit::Cache::Module::Instance} that have (1) 'payload' for {Metasploit::Cache::Module::Instance#module_type}; (2) a least 1
  #   {Metasploit::Cache::Architecture} shared between the {Metasploit::Cache::Module::Instance#architectures} and this target's {#architectures};
  #   (3) at least one shared platform or platform descendant between {Metasploit::Cache::Module::Instance#platforms} and this
  #   target's {#platforms} or their descendants; and, optionally, (4) that are NOT {Metasploit::Cache::Module::Instance#privileged?}
  #   if and only if {Metasploit::Cache::Module::Target#module_instance} is NOT {Metasploit::Cache::Module::Instance#privileged?}.
  #
  #   @param module_target [Metasploit::Cache::Module::Target] target with {Metasploit::Cache::Module::Target#architectures} and
  #     {Metasploit::Cache::Module::Target#platforms} that need to be compatible with the returned payload
  #     {Metasploit::Cache::Module::Instance Metasploit::Cache::Module::Instances}.
  #   @return [ActiveRecord::Relation<Metasploit::Cache::Module::Instance>]
  scope :payloads_compatible_with,
        ->(module_target){
          with_module_type(
              'payload'
          ).compatible_privilege_with(
              module_target.module_instance
          ).intersecting_architectures_with(
              module_target
          ).intersecting_platforms_with(
              module_target
          ).ranked
        }

  #
  #
  # Search
  #
  #

  #
  # Search Associations
  #

  search_association :actions
  search_association :architectures
  search_association :authorities
  search_association :authors
  search_association :email_addresses
  search_association :module_class
  search_association :platforms
  search_association :rank
  search_association :references
  search_association :targets

  #
  # Search Attributes
  #

  search_attribute :description, :type => :string
  search_attribute :disclosed_on, :type => :date
  search_attribute :license, :type => :string
  search_attribute :name, :type => :string
  search_attribute :privileged, :type => :boolean
  search_attribute :stance, :type => :string

  #
  # Search Withs
  #

  search_with Metasploit::Cache::Search::Operator::Deprecated::App
  search_with Metasploit::Cache::Search::Operator::Deprecated::Author
  search_with Metasploit::Cache::Search::Operator::Deprecated::Authority,
              :abbreviation => :bid
  search_with Metasploit::Cache::Search::Operator::Deprecated::Authority,
              :abbreviation => :cve
  search_with Metasploit::Cache::Search::Operator::Deprecated::Authority,
              :abbreviation => :edb
  search_with Metasploit::Cache::Search::Operator::Deprecated::Authority,
              :abbreviation => :osvdb
  search_with Metasploit::Cache::Search::Operator::Deprecated::Platform,
              :name => :os
  search_with Metasploit::Cache::Search::Operator::Deprecated::Platform,
              :name => :platform
  search_with Metasploit::Cache::Search::Operator::Deprecated::Ref
  search_with Metasploit::Cache::Search::Operator::Deprecated::Text

  #
  #
  # Validations
  #
  #

  #
  # Method validations
  #

  validate :architectures_from_targets,
           if: 'allows?(:targets)'
  validate :platforms_from_targets,
           if: 'allows?(:targets)'

  #
  # Attribute validations
  #

  validates :actions,
            dynamic_length: true
  validates :default_action_id,
            uniqueness: {
                allow_nil: true,
                unless: :batched?
            }
  validates :default_target_id,
            uniqueness: {
                allow_nil: true,
                unless: :batched?
            }
  validates :description,
            presence: true
  validates :license,
            presence: true
  validates :module_architectures,
            dynamic_length: true
  validates :module_authors,
            length: {
                minimum: MINIMUM_MODULE_AUTHORS_LENGTH
            }
  validates :module_class,
            presence: true
  validates :module_class_id,
            uniqueness: {
                unless: :batched?
            }
  validates :module_platforms,
            dynamic_length: true
  validates :module_references,
            dynamic_length: true
  validates :name,
            presence: true
  validates :privileged,
            inclusion: {
                in: PRIVILEGES
            }
  validates :stance,
            inclusion: {
                if: :stanced?,
                in: Metasploit::Cache::Module::Stance::ALL
            },
            nil: {
                unless: :stanced?
            }
  validates :targets,
            dynamic_length: true

  #
  # Class Methods
  #

  # Whether the given `:attribute` is allowed to be present for the given `:module_type`.  An attribute is
  # considered allowed if it allows greatrr than 0 elements for a collection.
  #
  # @raise [KeyError] if `:attribute` is not given in `options`.
  # @raise [KeyError] if `:module_type` is not given in `options`.
  # @return [true] if maximum elements is greater than 0 or value can be non-nil
  def self.allows?(options={})
    allowed = false
    length_validation_options = dynamic_length_validation_options(options)

    is = length_validation_options[:is]

    if is
      if is > 0
        allowed = true
      end
    else
      maximum = length_validation_options[:maximum]

      if maximum
        if maximum > 0
          allowed = true
        end
      else
        # if there is no maximum, then it's treated as infinite
        allowed = true
      end
    end

    allowed
  end

  # The length validation options for the given `:attribute` and `:module_type`.
  # @return [Hash{Symbol => Integer}] Hash containing either `:is` (meaning :maximum and :minimum are the same) or
  #   `:minimum` (no attribute has an explicit :maximum currently).
  # @raise [KeyError] if `:attribute` is not given in `options`.
  # @raise [KeyError] if `:module_type` is not given in `options`.
  # @raise [KeyError] if `:attribute` value is not a key in
  #   {DYNAMIC_LENGTH_VALIDATION_OPTIONS_BY_MODULE_TYPE_BY_ATTRIBUTE}.
  # @raise [KeyError] if `:module_type` value is a not a {Metasploit::Cache::Module::Type::ALL} member.
  def self.dynamic_length_validation_options(options={})
    options.assert_valid_keys(:attribute, :module_type)
    attribute = options.fetch(:attribute)
    module_type = options.fetch(:module_type)

    dynamic_length_validation_options_by_module_type = DYNAMIC_LENGTH_VALIDATION_OPTIONS_BY_MODULE_TYPE_BY_ATTRIBUTE.fetch(attribute)
    dynamic_length_validation_options_by_module_type.fetch(module_type)
  end

  # Values of {#module_type} (members of {Metasploit::Cache::Module::Type::ALL}), which have an exact length
  # (`:is`) or maximum length (`:maximum`) greater than 0 for the given `attribute`.
  #
  # @return [Array<String>] Array with members of {Metasploit::Cache::Module::Type::ALL}.
  # @see DYNAMIC_LENGTH_VALIDATION_OPTIONS_BY_MODULE_TYPE_BY_ATTRIBUTE
  def self.module_types_that_allow(attribute)
    dynamic_length_validation_options_by_module_type = DYNAMIC_LENGTH_VALIDATION_OPTIONS_BY_MODULE_TYPE_BY_ATTRIBUTE.fetch(attribute)

    dynamic_length_validation_options_by_module_type.each_with_object([]) { |(module_type, dynamic_length_validation_options), module_types|
      is = dynamic_length_validation_options[:is]

      if is
        if is > 0
          module_types << module_type
        end
      else
        maximum = dynamic_length_validation_options[:maximum]

        if maximum
          if maximum > 0
            module_types << module_type
          end
        else
          module_types << module_type
        end
      end

    }
  end

  # Whether the `:module_type` requires stance to be in {Metasploit::Cache::Module::Stance::ALL} or if it must
  # be `nil`.
  #
  # @param module_type [String] A member of `Metasploit::Cache::Module::Type::ALL`.
  # @return [true] if `module_type` is in {STANCED_MODULE_TYPES}.
  # @return [false] otherwise.
  def self.stanced?(module_type)
    STANCED_MODULE_TYPES.include? module_type
  end

  #
  # Instance Methods
  #

  # @!method actions=(actions)
  #   Sets {#actions}.
  #
  #   @param actions [Array<Metasploit::Cache::Module::Action>] Auxiliary actions to perform when this running this
  #     module.
  #   @return [void]

  # Whether the given `attribute` is allowed to have elements.
  #
  # @param attribute [Symbol] name of attribute to check if {#module_type} allows it to have one or more
  #   elements.
  # @return (see Metasploit::Cache::Module::Instance::ClassMethods#allows?)
  # @return [false] if {#module_type} is not valid
  def allows?(attribute)
    if Metasploit::Cache::Module::Type::ALL.include? module_type
      self.class.allows?(
          attribute: attribute,
          module_type: module_type
      )
    else
      false
    end
  end

  # @!method default_action=(default_action)
  #   Sets {#default_action}.
  #
  #   @param default_action [Metasploit::Cache::Module::Action] The default action in {#actions}.
  #   @return [void]

  # @!method default_target=(default_target)
  #   Sets {#default_target}.
  #
  #   @param default_target [Metasploit::Cache::Module::Target] the default target in {#targets}.
  #   @return [void]

  # @!method description=(description)
  #   Sets {#description}.
  #
  #   @param description [String] A long, paragraph description of what the module does.
  #   @return [void]

  # @!method disclosed_on=(disclosed_on)
  #   Sets {#disclosed_on}.
  #
  #   @param disclosed_on [Date, nil] the date the vulnerability exploited by this module was disclosed to the
  #     public.
  #   @return [void]

  # The dynamic length valdiations, such as `:is` and `:minimum` for the given attribute for the current
  # {#module_type}.
  #
  # @param attribute [Symbol] name of attribute whose dynamic length validation options to be
  # @return (see Metasploit::Cache::Module::Instance::ClassMethods#dynamic_length_validation_options)
  # @return [{}] an empty Hash if {#module_type} is not a member of {Metasploit::Cache::Module::Type::ALL}
  def dynamic_length_validation_options(attribute)
    if Metasploit::Cache::Module::Type::ALL.include? module_type
      self.class.dynamic_length_validation_options(
          module_type: module_type,
          attribute: attribute
      )
    else
      {}
    end
  end

  # @!method license=(license)
  #   Sets {#license}.
  #
  #   @param license [String] The name of the software license for the module's code.
  #   @return [void]

  # @!method module_architectures=(module_architectures)
  #   Sets {#module_architectures}.
  #
  #   @param module_architectures [Array<Metasploit::Cache::Module::Architecture>] Joins this with {#architectures}.
  #   @return [void]

  # @!method module_authors=(module_authors)
  #   Sets {#module_authors}.
  #
  #   @param module_authors [Array<Metasploit::Cache::Module::Author>] Joins this with {#authors} and {#email_addresses}
  #     to model the name and email address used for an author entry in the module metadata.
  #   @return [void]

  # @!method module_class=(module_class)
  #   Sets {#module_class}.
  #
  #   @param module_class [Metasploit::Cache::Module::Class] Class-derived metadata to go along with the
  #     instance-derived metadata in this model.
  #   @return [void]

  # @!method module_platforms=(module_platforms)
  #   Sets {#module_platforms}.
  #
  #   @param module_platforms [Enumerable<Metasploit::Cache::Module::Platform>] joins this with {#platforms}.
  #   @return [void]

  # @!method module_references=(module_references)
  #   Sets {#module_references}.
  #
  #   @param module_references [Enumerable<Metasploit::Cache::Module::Reference>, nil] Joins {#references} to this
  #     {Metasploit::Cache::Module::Instance}.
  #   @return [void]

  # @!method module_type
  #   The {Metasploit::Cache::Module::Class#module_type} of the {#module_class}.
  #
  #   @return (see Metasploit::Cache::Module::Class#module_type)
  delegate :module_type,
           allow_nil: true,
           to: :module_class

  # @!method name=(name)
  #   Sets {#name}.
  #
  #   @param name [String] The human readable name of the module.  It is unrelated to
  #     {Metasploit::Cache::Module::Class#full_name} or {Metasploit::Cache::Module::Class#reference_name} and is better
  #     thought of as a short summary of the {#description}.
  #   @return [void]

  # @!method privileged=(privileged)
  #   Sets {#priviledged}.
  #
  #   @param priviledged [Boolean] Whether this module requires privileged access to run.
  #   @return [void]

  # @!method stance=(stance)
  #   Sets {#stance}.
  #
  #   @param stance ['active', 'passive', nil] Whether the module is active or passive; `nil` if the {#module_type} is
  #     not {#stanced?}.
  #   @return [void]

  # Whether {#module_type} requires {#stance} to be set or to be `nil`.
  #
  # @return (see Metasploit::Cache::Module::Instance::ClassMethods#stanced?)
  # @return [false] if {#module_type} is not valid
  def stanced?
    self.class.stanced?(module_type)
  end

  # @!method targets=(targets)
  #   Sets {#targets}.
  #
  #   @param targets [Array<Metasploit::Cache::Module::Target>] Targets with different configurations that can be
  #     exploited by this module.
  #   @return [void]

  # Comment break to make {#targets=} docs work above `private`

  private

  # Validates that the {#module_architectures}
  # {Metasploit::Cache::Module::Architecture#architecture architectures} match the {#targets}
  # {Metasploit::Cache::Module::Target#target_architectures target_architectures}
  # {Metasploit::Cache::Module::Target::Architecture#architecture architectures}.
  #
  # @return [void]
  def architectures_from_targets
    actual_architecture_set = Set.new module_architectures.map(&:architecture)
    expected_architecture_set = Set.new

    targets.each do |module_target|
      module_target.target_architectures.each do |target_architecture|
        expected_architecture_set.add target_architecture.architecture
      end
    end

    extra_architecture_set = actual_architecture_set - expected_architecture_set

    unless extra_architecture_set.empty?
      human_extra_architectures = human_architecture_set(extra_architecture_set)

      errors.add(:architectures, :extra, extra: human_extra_architectures)
    end

    missing_architecture_set = expected_architecture_set - actual_architecture_set

    unless missing_architecture_set.empty?
      human_missing_architectures = human_architecture_set(missing_architecture_set)

      errors.add(:architectures, :missing, missing: human_missing_architectures)
    end
  end

  # Converts a Set<Metasploit::Cache::Architecture> to a human readable representation including the
  # {Metasploit::Cache::Architecture#abbreviation}.
  #
  # @return [String]
  def human_architecture_set(architecture_set)
    abbreviations = architecture_set.map(&:abbreviation)

    human_set(abbreviations)
  end

  # Converts a Set<Metasploit::Cache::Platform> to a human-readable representation including the
  # {Metasploit::Cache::Platform#fully_qualified_name}.
  #
  # @return [String]
  def human_platform_set(platform_set)
    fully_qualified_names = platform_set.map(&:fully_qualified_name)

    human_set(fully_qualified_names)
  end

  # Converts strings to a human-readable set notation.
  #
  # @return [String]
  def human_set(strings)
    sorted = strings.sort
    comma_separated = sorted.join(', ')

    "{#{comma_separated}}"
  end

  # Validates that {#module_platforms} {Metasploit::Cache::Module::Platform#platform platforms} match the
  # {#targets} {Metasploit::Cache::Module::Target#target_platforms target_platforms}
  # {Metasploit::Cache::Module::Target::Platform#platform platforms}.
  #
  # @return [void]
  def platforms_from_targets
    actual_platform_set = Set.new module_platforms.map(&:platform)
    expected_platform_set = Set.new

    targets.each do |module_target|
      module_target.target_platforms.each do |target_platform|
        expected_platform_set.add target_platform.platform
      end
    end

    extra_platform_set = actual_platform_set - expected_platform_set

    unless extra_platform_set.empty?
      human_extra_platforms = human_platform_set(extra_platform_set)

      errors.add(:platforms, :extra, extra: human_extra_platforms)
    end

    missing_platform_set = expected_platform_set - actual_platform_set

    unless missing_platform_set.empty?
      human_missing_platforms = human_platform_set(missing_platform_set)

      errors.add(:platforms, :missing, missing: human_missing_platforms)
    end
  end

  # Switch back to public for load hooks
  public

  Metasploit::Concern.run(self)
end
