# 1. A ruby Class defined in one {Metasploit::Cache::Module::Ancestor#relative_path path} for non-payloads.
# 2. A ruby Class with one or more ruby Modules mixed into the Class from
#    {Metasploit::Cache::Module::Ancestor#relative_path multiple paths} for payloads.
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

  # Instance-derived metadata to go along with the class-derived metadata from this model.
  has_one :module_instance,
          class_name: 'Metasploit::Cache::Module::Instance',
          dependent: :destroy,
          foreign_key: :module_class_id,
          inverse_of: :module_class
 
  # The reliability of the module and likelyhood that the module won't knock over the service or host being exploited.
  # Bigger values are better.
  belongs_to :rank, class_name: 'Metasploit::Cache::Module::Rank', inverse_of: :module_classes
 
  # Join model between {Metasploit::Cache::Module::Class} and {Metasploit::Cache::Module::Ancestor} that represents
  # that the Class or Module in {Metasploit::Cache::Module::Ancestor#real_path} is an ancestor of the Class
  # represented by this {Metasploit::Cache::Module::Class}.
  has_many :relationships,
           class_name: 'Metasploit::Cache::Module::Relationship',
           dependent: :destroy,
           foreign_key: :descendant_id,
           inverse_of: :descendant
 
  #
  # through: :relationships
  #
  
  # The Class or Modules that were loaded to make this module Class.
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

  # Derives {#payload_type} based on {#ancestors ancestor's} {Metasploit::Cache::Module::Ancestor#module_type}.
  #
  # @return ['single'] if {#payload?} and single ancestor is a payload.
  # @return [nil] otherwise
  def derived_payload_type
    derived = nil

    if payload? && ancestors.length ==  1 && ancestors.first.module_type == Metasploit::Cache::Module::Type::PAYLOAD
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
      end
    else
      if ancestors.length == 1
        derived = ancestors.first.reference_name
      end
    end

    derived
  end

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
                              "#{ancestor.module_type}/#{ancestor.reference_name} cannot be an ancestor due to its " \
                              "module_type (#{ancestor.module_type})"
      end

      ancestor_module_type_set.add ancestor.module_type
    end

    if ancestor_module_type_set.length > 1
      ancestor_module_type_sentence = ancestor_module_type_set.sort.to_sentence
      errors[:ancestors] << "can only contain ancestors with one module_type, " \
                            "but contains multiple module_types (#{ancestor_module_type_sentence})"
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

      if ancestor.module_type == Metasploit::Cache::Module::Type::PAYLOAD
        derived = ancestor.payload_name
      end
    end

    derived
  end

  # switch back to public for load hooks
  public
  
  Metasploit::Concern.run(self)
end
