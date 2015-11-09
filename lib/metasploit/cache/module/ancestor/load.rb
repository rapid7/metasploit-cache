# Loads a {Metasploit::Cache::Module::Ancestor}.  Any load errors are recorded as validation errors on this load.
class Metasploit::Cache::Module::Ancestor::Load < Metasploit::Model::Base
  #
  # Attributes
  #

  # @!attribute logger
  #   Tagged logger to which to log loading errors.
  #
  #   @return [ActiveSupport::TaggedLogging]
  attr_accessor :logger

  # @!attribute maximum_version
  #   The maximum version number that should be allowed to load as indicated by the *N* in `MetasploitN` class
  #   or module name.
  #
  #   @return [Fixnum]
  attr_accessor :maximum_version

  # @!attribute module_ancestor
  #   The module ancestor being loaded.
  #
  #   @return [Metasploit::Cache::Module::Ancestor]
  attr_accessor :module_ancestor

  #
  # Validations
  #

  validate :module_ancestor_valid
  validate :namespace_module_valid,
           unless: :loading_context?

  #
  # Attribute Validations
  #

  validates :logger,
            presence: true
  validates :maximum_version,
            numericality: {
                greater_than_or_equal_to: 1,
                only_integer: true
            }
  validates :metasploit_module,
            unless: :loading_context?,
            presence: true
  validates :module_ancestor,
            presence: true


  #
  # Methods
  #

  # `Metasploit<n>` ruby `Module` declared in {#module_ancestor module_ancestor's}
  # {Metasploit::Cache::Module::Ancestor#contents}.
  #
  # @return [Module]
  def metasploit_module
    namespace_module = self.namespace_module

    if namespace_module
      namespace_module.load.metasploit_module
    else
      nil
    end
  end

  # @note Calling this method (either directly or by validating this module ancestor load) will both declare the
  #   namespace `Module` and evaluate {Metasploit::Cache::Module::Ancestor#contents} within that `Module`, so at the end
  #   of the call, assuming the `Modules` are valid and there are no exceptions, both `Modules` will be bound to
  #   constants in this process's memory space.
  # @note Once this method is called (after being valid for loading), its results are memoized to reflect that there
  #   were errors with the {Metasploit::Cache::Module::Ancestor#contents} or the constants now exist in the memory
  #   space. To reload the {Metasploit::Cache::Module::Ancestor} for a change to {Metasploit::Cache::Module::Ancestor},
  #   create a new {Metasploit::Cache::Module::Ancestor::Load}.
  #
  # Ruby `Module` that wraps {#metasploit_module} to prevent it from overriding the `Metasploit<n>` from other
  # {Metasploit::Cache::Module::Ancestor#contents}.
  #
  # @return [nil] if this module ancestor load is not valid for loading.
  # @return [nil] if {#module_ancestor} could not be
  #   {Metasploit::Cache::Module::Namespace::Load#module_ancestor_eval evaluated} into the namespace `Module`.
  # @return [Module<Metasploit::Cache::Module::Namespace::Cacheable, Metasploit::Cache::Module::Namespace::Loadable>]
  #   otherwise
  def namespace_module
    unless instance_variable_defined? :@namespace_module
      if valid?(:loading)
        Metasploit::Cache::Module::Namespace.transaction(module_ancestor) do |module_ancestor, namespace_module|
          commit = false
          @namespace_module = nil

          namespace_module_load = namespace_module.load
          namespace_module_load.logger = logger
          namespace_module_load.maximum_version = maximum_version

          if namespace_module_load.module_ancestor_eval(module_ancestor)
            @namespace_module = namespace_module
            @namespace_module_load_errors = nil

            commit = true
          else
            # since namespace_module is being reverted, we need to keep a copy of the validation errors without a copy
            # of namespace_module.
            namespace_module_load.valid?
            @namespace_module_load_errors = namespace_module_load.errors
          end

          commit
        end
      end
    end

    @namespace_module
  end

  # Caches {#namespace_module} {Metasploit::Cache::Module::Namespace::Loadable#load} validation errors in case
  # {#namespace_module} is `nil` because its construction or the {#metasploit_module} construction is invalid.
  #
  # @return [ActiveModel::Errors]
  def namespace_module_load_errors
    unless instance_variable_defined? :@namespace_module_load_errors
      @namespace_module_load_errors = nil

      # attempt to load namespace_module to populate @namespace_module_load_errors
      namespace_module
    end

    @namespace_module_load_errors
  end

  private

  # Whether the current `#validation_context` is `:loading`.
  #
  # @return [true] if `#validation_context` is `:loading`.
  # @return [false] otherwise
  def loading_context?
    validation_context == :loading
  end

  # Validates that {#module_ancestor} is valid, but only if {#module_ancestor} is not `nil`.
  #
  # @return [void]
  def module_ancestor_valid
    # allow the presence validation to handle it being nil
    if module_ancestor and module_ancestor.invalid?(validation_context)
      errors.add(:module_ancestor, :invalid)
    end
  end

  # Validates that there are no {#namespace_module_load_errors}.
  #
  # @return [void]
  def namespace_module_valid
    if namespace_module_load_errors
      namespace_module_load_errors.each do |attribute, attribute_error|
        errors.add(:"namespace_module.#{attribute}", attribute_error)
      end
    end
  end
end