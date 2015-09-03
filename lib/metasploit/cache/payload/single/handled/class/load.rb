# Loads a {Metasploit::Cache::Payload::Single::Handled::Class}.
class Metasploit::Cache::Payload::Single::Handled::Class::Load < Metasploit::Model::Base
  #
  # CONSTANTS
  #

  # The base namespace name under which {metasploit_class_names} are generated.
  METASPLOIT_CLASS_NAMES = ['Msf', 'Payloads', 'Handled']

  #
  # Attributes
  #

  # The Module of the connection handler of the payload single unhandled Metasploit Module instance of the payload
  # single unhandled Metasploit Module class of the {#metasploit_module}
  #
  # @return [Module]
  attr_accessor :handler_module

  # Tagged logger to which to load loading errors.
  #
  # @return [ActiveSupport::TaggedLogging]
  attr_accessor :logger

  # `Metasploit<n>` ruby `Module` declared in {Metasploit::Cache::Module::Ancestor#contents} for single payload
  # Metasploit Module ancestor.
  #
  # @return [Module<Metasploit::Cache::Cacheable>] Must be have a `ephemeral_cache_by_source[:ancestor]`.
  attr_accessor :metasploit_module

  # The payload single handled class being loaded.
  #
  # @return [Metasploit::Cache::Payload::Single::Handled::Class]
  attr_accessor :payload_single_handled_class

  # The superclass to subclass and include {#metasploit_module} into.
  #
  # @return [Class, #rank, #is_usable]
  attr_accessor :payload_superclass

  #
  #
  # Validations
  #
  #

  #
  # Method Validations
  #

  validate :payload_single_handled_class_valid

  #
  # Attribute Validations
  #

  validates :handler_module,
            presence: true
  validates :logger,
            presence: true
  validates :metasploit_class,
            presence: {
                unless: :loading_context?
            }
  validates :metasploit_module,
            presence: true
  validates :payload_single_handled_class,
            presence: true
  validates :payload_superclass,
            presence: true

  #
  # Class Methods
  #

  # Includes `ancestor_module` in `base` and records `ancestor_module` as the `source` ancestor in
  # `base.ancestor_by_source`.
  #
  # @param base [Metasploit::Cache::Ancestry] base module on which `include` is called.
  # @param source [:handler, :stage, :stager] The symbolic name of the `ancestor_module`
  # @param ancestor [Module] module to include in `base`.
  # @return [void]
  def self.include_ancestor(base, source, ancestor)
    base.include ancestor
    base.ancestor_by_source[source] = ancestor
  end

  # Returns names for the {#metasploit_class} and its namespaces.
  #
  # @param payload_single_handled_class [Metasploit::Cache::Payload::Single::Handled::Class] Whose names to calculate
  # @return [Array<String>]
  def self.metasploit_class_names(payload_single_handled_class)
    payload_single_ancestor = payload_single_handled_class.payload_single_unhandled_instance.payload_single_unhandled_class.ancestor

    METASPLOIT_CLASS_NAMES + ["RealPathSha1HexDigest#{payload_single_ancestor.real_path_sha1_hex_digest}"]
  end

  #
  # Instance Methods
  #

  # Subclass of {#payload_superclass} with {#handler_module} and {#metasploit_module} mixed in.
  #
  # @return [Class]
  def metasploit_class
    unless instance_variable_defined? :@metasploit_class
      if valid?(:loading)
        @metasploit_class = nil

        metasploit_class = Class.new(payload_superclass)
        metasploit_class.extend Metasploit::Cache::Ancestry
        metasploit_class.extend Metasploit::Cache::Cacheable

        # Defer to the single first, ten the single's handler.  Remember, the last
        # module included is the first ancestor whose methods are used, so include order is opposite the desired
        # precedence.
        self.class.include_ancestor(metasploit_class, :handler, handler_module)
        self.class.include_ancestor(metasploit_class, :single, metasploit_module)

        ephemeral_cache = Metasploit::Cache::Payload::Single::Handled::Class::Ephemeral.new(
            logger: logger,
            payload_single_handled_metasploit_module_class: metasploit_class
        )

        metasploit_class.ephemeral_cache_by_source[:class] = ephemeral_cache

        if ephemeral_cache.valid?
          ephemeral_cache.persist(to: payload_single_handled_class)

          if payload_single_handled_class.persisted?
            # Name class so that it can be looked up by name to prevent unnecessary reloading.
            Metasploit::Cache::Constant.name(
                constant: metasploit_class,
                names: self.class.metasploit_class_names(payload_single_handled_class)
            )
            # The load only succeeded if the metadata was persisted, so @metasploit_class is `nil` otherwise.
            @metasploit_class = metasploit_class
          end
        end
      end
    end

    @metasploit_class
  end

  private

  # Validates that {#payload_single_handled_class} is valid, but only if {#payload_single_handled_class} is not `nil`.
  #
  # @return [void]
  def payload_single_handled_class_valid
    # allow the presence validation to handle it being nil
    if payload_single_handled_class && payload_single_handled_class.invalid?
      errors.add(:payload_single_handled_class, :invalid)
    end
  end

  # Whether the current `#validation_context` is `:loading`.
  #
  # @return [true] if `#validation_context` is `:loading`.
  # @return [false] otherwise
  def loading_context?
    validation_context == :loading
  end
end