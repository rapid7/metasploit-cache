# Details about an Msf::Module.  Metadata that can be an array is stored in associations in modules under the
# {Metasploit::Cache::Module} namespace.
class Metasploit::Cache::Module::Instance < ActiveRecord::Base
  extend ActiveSupport::Autoload

  include Metasploit::Cache::Batch::Root
  include Metasploit::Model::Search
  include Metasploit::Model::Translation

  autoload :Load
  autoload :Spec

  #
  # CONSTANTS
  #

  # {#dynamic_length_validation_options} by {#module_type} by attribute.
  DYNAMIC_LENGTH_VALIDATION_OPTIONS_BY_MODULE_TYPE_BY_ATTRIBUTE = {
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

  # The default target in {#targets}.
  belongs_to :default_target, class_name: 'Metasploit::Cache::Module::Target', inverse_of: :module_instance

  # Class-derived metadata to go along with the instance-derived metadata in this model.
  belongs_to :module_class, class_name: 'Metasploit::Cache::Module::Class', inverse_of: :module_instance

  # Joins {#references} to this {Metasploit::Cache::Module::Instance}.
  has_many :module_references,
           class_name: 'Metasploit::Cache::Module::Reference',
           dependent: :destroy,
           foreign_key: :module_instance_id,
           inverse_of: :module_instance

  # Names of targets with different configurations that can be exploited by this module.
  has_many :targets,
           class_name: 'Metasploit::Cache::Module::Target',
           dependent: :destroy,
           foreign_key: :module_instance_id,
           inverse_of: :module_instance

  #
  # through: :module_class
  #

  # The rank of this module.
  has_one :rank, :class_name => 'Metasploit::Cache::Module::Rank', :through => :module_class

  #
  # through: :module_references
  #

  # External references to the exploit or proof-of-concept (PoC) code in this module.
  has_many :references, :class_name => 'Metasploit::Cache::Reference', :through => :module_references

  #
  # through: :references
  #

  # Authorities across all {#references} to this module.
  has_many :authorities, :class_name => 'Metasploit::Cache::Authority', :through => :references, :uniq => true

  #
  # Attributes
  #

  # @!method default_target_id
  #   The primary key of the associated {#default_target}.
  #
  #   @return [Integer, nil]

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

  # @!method module_class_id
  #   The primary key of the associated {#module_class}.
  #
  #   @return [Integer, nil]

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

  # @!method self.order_by_rank
  #   Orders {Metasploit::Cache::Module::Instance Metasploit::Cache::Module::Instances} by their {#module_class} {Metasploit::Cache::Module::Class#rank}
  #   {Metasploit::Cache::Module::Rank#number} in descending order so better, more reliable modules are first.
  #
  #   @return [ActiveRecord::Relation<Metasploit::Cache::Module::Instance>]
  #   @see Metasploit::Cache::Module::Class.order_by_rank
  scope :order_by_rank,
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

  #
  #
  # Search
  #
  #

  #
  # Search Associations
  #

  search_association :authorities
  search_association :module_class
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
  search_with Metasploit::Cache::Search::Operator::Deprecated::Authority,
              :abbreviation => :bid
  search_with Metasploit::Cache::Search::Operator::Deprecated::Authority,
              :abbreviation => :cve
  search_with Metasploit::Cache::Search::Operator::Deprecated::Authority,
              :abbreviation => :edb
  search_with Metasploit::Cache::Search::Operator::Deprecated::Authority,
              :abbreviation => :osvdb
  search_with Metasploit::Cache::Search::Operator::Deprecated::Ref
  search_with Metasploit::Cache::Search::Operator::Deprecated::Text

  #
  # Validations
  #

  validates :default_target_id,
            uniqueness: {
                allow_nil: true,
                unless: :batched?
            }
  validates :description,
            presence: true
  validates :license,
            presence: true
  validates :module_class,
            presence: true
  validates :module_class_id,
            uniqueness: {
                unless: :batched?
            }
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

  # @!method module_type
  #   The {Metasploit::Cache::Module::Class#module_type} of the {#module_class}.
  #
  #   @return (see Metasploit::Cache::Module::Class#module_type)
  delegate :module_type,
           allow_nil: true,
           to: :module_class

  # Whether {#module_type} requires {#stance} to be set or to be `nil`.
  #
  # @return (see Metasploit::Cache::Module::Instance::ClassMethods#stanced?)
  # @return [false] if {#module_type} is not valid
  def stanced?
    self.class.stanced?(module_type)
  end

  private

  # Converts strings to a human-readable set notation.
  #
  # @return [String]
  def human_set(strings)
    sorted = strings.sort
    comma_separated = sorted.join(', ')

    "{#{comma_separated}}"
  end

  # Switch back to public for load hooks
  public

  Metasploit::Concern.run(self)
end
