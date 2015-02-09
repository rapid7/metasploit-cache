# Code shared between `Mdm::Module::Instance` and `Metasploit::Framework::Module::Instance`.
module Metasploit::Cache::Module::Instance
  extend ActiveModel::Naming
  extend ActiveSupport::Autoload
  extend ActiveSupport::Concern

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

  included do
    include ActiveModel::Validations
    include Metasploit::Model::Search

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
    # Method Validations
    #

    validate :architectures_from_targets,
             if: 'allows?(:targets)'
    validate :platforms_from_targets,
             if: 'allows?(:targets)'

    #
    # Attribute Validations
    #

    validates :actions,
              dynamic_length: true
    validates :description,
              :presence => true
    validates :license,
              :presence => true
    validates :module_architectures,
              dynamic_length: true
    validates :module_authors,
              :length => {
                  :minimum => MINIMUM_MODULE_AUTHORS_LENGTH
              }
    validates :module_class,
              :presence => true
    validates :module_platforms,
              dynamic_length: true
    validates :module_references,
              dynamic_length: true
    validates :name,
              :presence => true
    validates :privileged,
              :inclusion => {
                  :in => PRIVILEGES
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
  end

  #
  #
  # Associations
  #
  #

  # @!attribute actions
  #   Auxiliary actions to perform when this running this module.
  #
  #   @return [Array<Metasploit::Cache::Module::Action>]

  # @!attribute default_action
  #   The default action in {#actions}.
  #
  #   @return [Metasploit::Cache::Module::Action]

  # @!attribute default_target
  #   The default target in {#targets}.
  #
  #   @return [Metasploit::Cache::Module::Target]

  # @!attribute module_architectures
  #   Joins this with {#architectures}.
  #
  #   @return [Array<Metasploit::Cache::Module::Architecture>]

  # @!attribute module_authors
  #   Joins this with {#authors} and {#email_addresses} to model the name and email address used for an author
  #   entry in the module metadata.
  #
  #   @return [Array<Metasploit::Cache::Module::Author>]

  # @!attribute module_class
  #   Class-derived metadata to go along with the instance-derived metadata in this model.
  #
  #   @return [Metasploit::Cache::Module::Class]

  # @!attribute module_platforms
  #   Joins this with {#platforms}.
  #
  #   @return [Array<Metasploit::Cache::Module::Platform>]

  # @!attribute targets
  #   Targets with different configurations that can be exploited by this module.
  #
  #   @return [Array<Metasploit::Cache::Module::Target>]

  # @!attribute [r] architectures
  #   The {Metasploit::Cache::Architecture architectures} supported by this module.
  #
  #   @return [Array<Metasploit::Cache::Architecture>]

  # @!attribute [r] authors
  #   The names of the authors of this module.
  #
  #   @return [Array<Metasploit::Cache::Author>]

  # @!attribute [r] email_addresses
  #   The email addresses of the authors of this module.
  #
  #   @return [Array<Metasploit::Cache::EmailAddress>]

  # @!attribute [r] platforms
  #   Platforms supported by this module.
  #
  #   @return [Array<Metasploit::Cache::Module::Platform>]

  # @!attribute [r] references
  #   External references to the exploit or proof-of-concept (PoC) code in this module.
  #
  #   @return [Array<Metasploit::Cache::Reference>]

  # @!attribute [r] vulns
  #   Vulnerabilities with same {Metasploit::Cache::Reference reference} as this module.
  #
  #   @return [Array<Metasploit::Cache::Vuln>]

  # @!attribute [r] vulnerable_hosts
  #   Hosts vulnerable to this module.
  #
  #   @return [Array<Metasploit::Cache::Host>]

  # @!attribute [r] vulnerable_services
  #   Services vulnerable to this module.
  #
  #   @return [Array<Metasploit::Cache::Service>]

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
  #   {Metasploit::Cache::Module::Class#reference_name} and is better thought of as a short summary of the
  #   {#description}.
  #
  #   @return [String]

  # @!attribute privileged
  #   Whether this module requires privileged access to run.
  #
  #   @return [Boolean]

  # @!attribute stance
  #   Whether the module is active or passive.  `nil` if the {#module_type} is not {#stanced?}.
  #
  #   @return ['active', 'passive', nil]

  #
  # Module Methods
  #

  module ClassMethods
    # Whether the given `:attribute` is allowed to be present for the given `:module_type`.  An attribute is
    # considered allowed if it allows greatrr than 0 elements for a collection.
    #
    # @raise [KeyError] if `:attribute` is not given in `options`.
    # @raise [KeyError] if `:module_type` is not given in `options`.
    # @return [true] if maximum elements is greater than 0 or value can be non-nil
    def allows?(options={})
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
    def dynamic_length_validation_options(options={})
      options.assert_valid_keys(:attribute, :module_type)
      attribute = options.fetch(:attribute)
      module_type = options.fetch(:module_type)

      dynamic_length_validation_options_by_module_type = DYNAMIC_LENGTH_VALIDATION_OPTIONS_BY_MODULE_TYPE_BY_ATTRIBUTE.fetch(attribute)
      dynamic_length_validation_options_by_module_type.fetch(module_type)
    end

    # Whether the `:module_type` requires stance to be in {Metasploit::Cache::Module::Stance::ALL} or if it must
    # be `nil`.
    #
    # @param module_type [String] A member of `Metasploit::Cache::Module::Type::ALL`.
    # @return [true] if `module_type` is in {STANCED_MODULE_TYPES}.
    # @return [false] otherwise.
    def stanced?(module_type)
      STANCED_MODULE_TYPES.include? module_type
    end
  end

  # make ClassMethods directly callable on Metasploit::Cache::Module::Instance for factories
  extend ClassMethods

  #
  # Module Methods
  #

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
  #   @param module_platforms [Array<Metasploit::Cache::Module::Platform>>] joins this with {#platforms}.
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
end
