# 1. A ruby Class defined in one {Metasploit::Cache::Module::Ancestor#real_path} for non-payloads.
# 2. A ruby Class with one or more ruby Modules mixed into the Class from {Metasploit::Cache::Module::Ancestor#real_path multiple paths}
#    for payloads.
class Metasploit::Cache::Module::Class < ActiveRecord::Base
  extend ActiveSupport::Autoload

  include Metasploit::Cache::Batch::Root
  include Metasploit::Cache::Derivation
  include Metasploit::Cache::Derivation::FullName
  include Metasploit::Model::Search
  include Metasploit::Model::Translation
  

  autoload :Spec

  #
  # CONSTANTS
  #

  # Valid values for {#payload_type} when {#payload?} is `true`.
  PAYLOAD_TYPES = [
      'single'
  ]

  # The {Metasploit::Cache::Module::Ancestor#payload_type} when {#payload_type} is 'staged'.
  STAGED_ANCESTOR_PAYLOAD_TYPES = [
      'stage',
      'stager'
  ]

  #
  #
  # Associations
  #
  #

  # @!attribute module_instance
  #   Instance-derived metadata to go along with the class-derived metadata from this model.
  #
  #   @return [Metasploit::Cache::Module::Instance, nil]
  has_one :module_instance,
          class_name: 'Metasploit::Cache::Module::Instance',
          dependent: :destroy,
          foreign_key: :module_class_id,
          inverse_of: :module_class
 
  # @!attribute rank
  #   The reliability of the module and likelyhood that the module won't knock over the service or host being
  #   exploited.  Bigger values is better.
  #
  #   @return [Metasploit::Cache::Module::Rank]
  belongs_to :rank, class_name: 'Metasploit::Cache::Module::Rank', inverse_of: :module_classes
 
  # @!attribute relationships
  #   Join model between {Metasploit::Cache::Module::Class} and {Metasploit::Cache::Module::Ancestor} that represents
  #   that the Class or Module in {Metasploit::Cache::Module::Ancestor#real_path} is an ancestor of the Class
  #   represented by this {Metasploit::Cache::Module::Class}.
  #
  #   @return [ActiveRecord::Relation<Metasploit::Cache::Module::Relationship>]
  has_many :relationships,
           class_name: 'Metasploit::Cache::Module::Relationship',
           dependent: :destroy,
           foreign_key: :descendant_id,
           inverse_of: :descendant
 
  #
  # through: :relationships
  #
  
  # @!attribute [r] ancestors
  #   The Class or Modules that were loaded to make this module Class.
  #
  #   @return [ActiveRecord::Relation<Metasploit::Cache::Module::Ancestor>]
  has_many :ancestors, class_name: 'Metasploit::Cache::Module::Ancestor', through: :relationships

  #
  # Attributes
  #

  # @!attribute full_name
  #   The full name (type + reference) for the Class<Msf::Module>.  This is merely a denormalized cache of
  #   `"#{{#module_type}}/#{{#reference_name}}"` as full_name is used in numerous queries and reports.
  #
  #   @return [String]

  # @!attribute module_type
  #   A denormalized cache of the {Metasploit::Cache::Module::Class#module_type ancestors' module_types}, which
  #   must all be the same.  This cache exists so that queries for modules of a given type don't need include the
  #   {#ancestors}.
  #
  #   @return [String]

  # @!attribute payload_type
  #   For payload modules, the {PAYLOAD_TYPES type} of payload, either 'single' or 'staged'.
  #
  #   @return [String] if {#payload?} is `true`.
  #   @return [nil] if {#payload?} is `false`

  # @!attribute reference_name
  #   The reference name for the Class<Msf::Module>. For non-payloads, this will just be
  #   {Metasploit::Cache::Module::Ancestor#reference_name} for the only element in {#ancestors}.  For payloads
  #   composed of a stage and stager, the reference name will be derived from the
  #   {Metasploit::Cache::Module::Ancestor#reference_name} of each element {#ancestors} or an alias defined in
  #   those Modules.
  #
  #   @return [String]

  #
  # Derivations
  #

  derives :module_type, :validate => true
  derives :payload_type, :validate => true
  # reference_name depends on module_type and conditionally depends on payload_type if module_type is 'payload'
  derives :reference_name, :validate => true

  # full_name depends on module_type and reference_name
  derives :full_name, :validate => true
  
  #
  # Scopes
  #

  # @!method self.non_generic_payloads
  #   Excludes generic payloads.
  #
  #   @return [ActiveRecord::Relation<Metasploit::Cache::Module::Class>]
  scope :non_generic_payloads,
        ->{
          where(
              module_type: 'payload'
          ).where(
              Metasploit::Cache::Module::Class.arel_table[:reference_name].does_not_match('generic/%')
          )
        }

  # @!method self.ranked
  #   Orders {Metasploit::Cache::Module::Class Metasploit::Cache::Module::Classes} by their {#rank}
  #   {Metasploit::Cache::Module::Rank#number} in descending order, so better, more reliable modules are first.
  #
  #   @return [ActiveRecord::Relation<Metasploit::Cache::Module::Class>]
  #   @see Metasploit::Cache::Module::Instance.ranked
  scope :ranked,
        ->{
          joins(
              :rank
          ).order(
              Metasploit::Cache::Module::Rank.arel_table[:number].desc
          )
        }

  # @!method self.with_module_instances(module_instances)
  #   {Metasploit::Cache::Module::Class Metasploit::Cache::Module::Classes} associated with the `module_instances`.
  #   Allows converting queries using {Metasploit::Cache::Module::Instance} scopes to
  #   {Metasploit::Cache::Module::Class} scopes.
  #
  #   @param module_instances [ActiveRecord::Relation<Metasploit::Cache::Module::Class>]
  #   @return [ActiveRecord::Relation<Metasploit::Cache::Module::Class>]
  scope :with_module_instances,
        ->(module_instances){
          module_class_ids = module_instances.joins(:module_class).select(Metasploit::Cache::Module::Class.arel_table[:id])
          where(id: module_class_ids)
        }
  
  #
  # Search Attributes
  #

  search_attribute :full_name, :type => :string
  search_attribute :module_type, :type => :string
  search_attribute :payload_type, :type => :string
  search_attribute :reference_name, :type => :string
  
  #
  #
  # Validations
  #
  #
  
  #
  # Method validations
  #

  validate :ancestors_size
  validate :ancestor_payload_types
  validate :ancestor_module_types
  
  #
  # Attribute validations
  #
  
  validates :full_name,
            uniqueness: {
                unless: :batched?
            }
  validates :module_type,
            :inclusion => {
                :in => Metasploit::Cache::Module::Type::ALL
            }
  validates :payload_type,
            :inclusion => {
                :if => :payload?,
                :in => PAYLOAD_TYPES
            },
            :nil => {
                :unless => :payload?
            }
  validates :rank,
            :presence => true
  validates :reference_name,
            presence: true,
            uniqueness: {
                scope: :module_type,
                unless: :batched?
            }

  #
  # Instance Methods
  #

  # Derives {#module_type} from the consensus of {#ancestors ancestors'}
  # {Metasploit::Cache::Module::Ancestor#module_type module_types}.
  #
  # @return [String] if all {#ancestors} have the same
  #   {Metasploit::Cache::Module::Ancestor#module_type module_type}.
  # @return [nil] if there are no {#ancestors}.
  # @return [nil] if {#ancestors} do not have the same
  #   {Metasploit::Cache::Module::Ancestor#module_type module_type}.
  def derived_module_type
    module_type_consensus = nil
    module_type_set = Set.new

    ancestors.each do |ancestor|
      module_type_set.add ancestor.module_type
    end

    if module_type_set.length == 1
      module_type_consensus = module_type_set.to_a.first
    end

    module_type_consensus
  end

  # Derives {#payload_type} based on {#ancestors ancestor's} {Metasploit::Cache::Module::Ancestor#payload? payloadness}.
  #
  # @return ['single'] if {#payload?} and single ancestor is a payload.
  # @return [nil] otherwise
  def derived_payload_type
    derived = nil

    if payload? && ancestors.length ==  1 && ancestors.first.payload?
      derived = 'single'
    end

    derived
  end

  # Derives {#reference_name} from {#ancestors}.
  #
  # @return [String] '<single_ancestor.reference_name>/<single_ancestor.handler_type>' if {#payload_type} is
  #   'single'.
  # @return [String] '<stage_ancestor.reference_name>/<stager_ancestor.handler_type>' if {#payload_type} is
  #   'staged'.
  # @return [String] '<ancestor.reference_name>' if not {#payload?}.
  # @return [nil] otherwise
  def derived_reference_name
    derived = nil

    if payload?
      case payload_type
        when 'single'
          derived = derived_single_payload_reference_name
        when 'staged'
          derived = derived_staged_payload_reference_name
      end
    else
      if ancestors.length == 1
        derived = ancestors.first.reference_name
      end
    end

    derived
  end

  # @!method module_instance=(module_instance)
  #   Sets {#module_instance}.
  #
  #   @param module_instance [Metasploit::Cache::Module::Instance, nil]
  #     Instance-derived metadata to go along with the class-derived metadata from this model.
  #   @return [void]

  # Returns whether this represents a Class<Msf::Payload>.
  #
  # @return [true] if {#module_type} == 'payload'
  # @return [false] if {#module_type} != 'payload'
  def payload?
    if module_type == 'payload'
      true
    else
      false
    end
  end

  # @!method relationships=(relationships)
  #   Sets {#relationships}.
  #
  #   @param relationships [Enumerable<Metasploit::Cache::Module::Relationship>, nil] Join model between
  #     {Metasploit::Cache::Module::Class} and {Metasploit::Cache::Module::Ancestor} that represents that the Class or
  #     Module in {Metasploit::Cache::Module::Ancestor#real_path} is an ancestor of the Class represented by this
  #     {Metasploit::Cache::Module::Class}.
  #   @return [void]

  # Comment break before private so above comment will be parsed correctly by YARD

  private

  # Validates that {#ancestors} all have the same {Metasploit::Cache::Module::Ancestor#module_type} as
  # {#module_type}.
  #
  # @return [void]
  def ancestor_module_types
    ancestor_module_type_set = Set.new

    ancestors.each do |ancestor|
      if module_type and ancestor.module_type != module_type
        errors[:ancestors] << "can contain ancestors only with same module_type (#{module_type}); " \
                              "#{ancestor.full_name} cannot be an ancestor due to its module_type " \
                              "(#{ancestor.module_type})"
      end

      ancestor_module_type_set.add ancestor.module_type
    end

    if ancestor_module_type_set.length > 1
      ancestor_module_type_sentence = ancestor_module_type_set.sort.to_sentence
      errors[:ancestors] << "can only contain ancestors with one module_type, " \
                            "but contains multiple module_types (#{ancestor_module_type_sentence})"
    end
  end

  # Validates that {#ancestors} are payloads when necessary for {#module_type}.
  #
  # @return [void]
  def ancestor_payload_types
    if payload?
      ancestors.each do |ancestor|
        unless ancestor.payload?
          errors[:ancestors] << "cannot have an ancestor (#{ancestor.full_name}) that is not a payload " \
                                "for payload class"
        end
      end
    else
      ancestors.each do |ancestor|
        if ancestor.payload?
          errors[:ancestors] << "cannot have an ancestor (#{ancestor.full_name}) " \
                                "that is a payload with " \
                                "for class module_type (#{module_type})"
        end
      end
    end
  end

  # Validates that number of {#ancestors} is correct for the {#module_type}.
  #
  # @return [void]
  def ancestors_size
    if payload?
      case payload_type
        when 'single'
          unless ancestors.size == 1
            errors[:ancestors] << 'must have exactly one ancestor for single payload module class'
          end
        when 'staged'
          unless ancestors.size == 2
            errors[:ancestors] << 'must have exactly two ancestors (stager + stage) for staged payload module class'
          end
        # other (invalid) types are handled by validation on payload_type
      end
    else
      unless ancestors.size == 1
        errors[:ancestors] << 'must have exactly one ancestor as a non-payload module class'
      end
    end
  end

  # @note Caller should check that {#payload?} is `true` and {#payload_type} is 'single' before calling
  #   {#derived_single_payload_reference_name}.
  #
  # Derives {#reference_name} for single payload.
  #
  # @return [String, nil] '<ancestor.payload_name>'
  # @return [nil] unless exactly one {#ancestors ancestor}.
  # @return [nil] unless ancestor's {Metasploit::Cache::Module::Ancestor#payload_type} is `'single'`.
  def derived_single_payload_reference_name
    derived = nil

    if ancestors.length == 1
      ancestor = ancestors.first

      if ancestor.payload?
        derived = ancestor.payload_name
      end
    end

    derived
  end

  # @note Caller should check that {#payload?} is `true` and {#payload_type} is 'staged' before calling
  #   {#derived_staged_payload_reference_name}.
  #
  # Derives {#reference_name} for staged payload.
  #
  # @return [String] '<stage_ancestor.payload_name>/<stager_ancestor.payload_name>'
  # @return [nil] unless exactly two {#ancestors ancestor}.
  # @return [nil] unless {Metasploit::Cache::Module::Ancestor#payload_type} is 'single'.
  # @return [nil] if {Metasploit::Cache::Module::Ancestor#payload_name} is `nil` for the stage.
  # @return [nil] if {Metasploit::Cache::Module::Ancestor#payload_name} is `nil` for the stager.
  def derived_staged_payload_reference_name
    derived = nil

    if ancestors.length == 2
      ancestors_by_payload_type = ancestors.group_by(&:payload_type)
      stage_ancestors = ancestors_by_payload_type.fetch('stage', [])

      # length can be 0..2
      if stage_ancestors.length == 1
        stage_ancestor = stage_ancestors.first

        if stage_ancestor.payload_name
          stager_ancestors = ancestors_by_payload_type.fetch('stager', [])

          # length can be 0..1
          if stager_ancestors.length == 1
            stager_ancestor = stager_ancestors.first

            if stager_ancestor.payload_name
              derived = "#{stage_ancestor.payload_name}/#{stager_ancestor.payload_name}"
            end
          end
        end
      end
    end

    derived
  end

  # @!method full_name=(full_name)
  #   Sets {#full_name}.
  #
  #   @param full_name [String] The full name (type + reference) for the Class<Msf::Module>.  This is merely a
  #     denormalized cache of `"#{{#module_type}}/#{{#reference_name}}"` as full_name is used in numerous queries and
  #     reports.
  #   @return [void]

  # @!method module_type=(module_type)
  #   Sets {#module_type}.
  #
  #   @param module_type [String] A denormalized cache of the
  #     {Metasploit::Cache::Module::Class#module_type ancestors' module_types}, which must all be the same.  This cache
  #     exists so that queries for modules of a given type don't need include the {#ancestors}.
  #   @return [void]


  # @!method payload_type=(payload_type)
  #   Sets {#payload_type}.
  #
  #   @param payload_type ['single', 'staged', nil] the payload type when {#payload?} `true`; otherwise `nil`.
  #   @return [void]

  # @!method rank=(rank)
  #   Sets {#rank}.
  #
  #   @param rank [Metasploit::Cache::Module::Rank] The reliability of the module and likelyhood that the module won't
  #     knock over the service or host being exploited.  Bigger values is better.
  #   @return [void]

  # @!method reference_name=(reference_name)
  #   Sets {#reference_name}.
  #
  #   @param reference_name [String] The reference name for the Class<Msf::Module>. For non-payloads, this will just be
  #     {Metasploit::Cache::Module::Ancestor#reference_name} for the only element in {#ancestors}.  For payloads
  #     composed of a stage and stager, the reference name will be derived from the
  #     {Metasploit::Cache::Module::Ancestor#reference_name} of each element {#ancestors} or an alias defined in those
  #     Modules.
  #   @return [void]

  # switch back to public for load hooks
  public
  
  Metasploit::Concern.run(self)
end
