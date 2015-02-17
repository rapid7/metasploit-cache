class Metasploit::Cache::Module::Namespace::Load < Metasploit::Model::Base
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

  # @!attribute maximum_api_version
  #   The maximum API version that is supported for the loading environment.
  #
  #   @return [Float]
  attr_accessor :maximum_api_version

  # @!attribute maximum_core_version
  #   The maximum core version that is supported for the loading environment.
  #
  #   @return [Float]
  attr_accessor :maximum_core_version

  # @!attribute [r] module_ancestor_eval_exception
  #   Exception raised in {#module_ancestor_eval}.
  #
  #   @return [nil] if {#module_ancestor_eval} has not run yet.
  #   @return [nil] if no exception was raised
  #   @return [Exception] if exception was raised
  attr_reader :module_ancestor_eval_exception

  # @!attribute module_namespace
  #   The namespace `Module` loading the Metasploit Module
  #
  #   @return [Module]
  attr_accessor :module_namespace

  #
  #
  # Validations
  #
  #

  #
  # Method Validations
  #

  validate :module_ancestor_eval_valid
  validate :metasploit_module_usable

  #
  # Attribute Validations
  #

  validates :metasploit_module,
            presence: true
  validates :minimum_api_version,
            allow_nil: true,
            numericality: {
                less_than_or_equal_to: :maximum_api_version
            }
  validates :minimum_core_version,
            allow_nil: true,
            numericality: {
                less_than_or_equal_to: :maximum_core_version
            }

  #
  # Instance Methods
  #

  # Returns the Metasploit<n> module from the module_evalled content.
  #
  # @note The `Metasploit::Model::Module::Ancestor#contents` must be module_evalled into this namespace module before
  #   the return of {#metasploit_module} is valid.
  #
  # @return [Msf::Module] if a Metasploit<n> `Module` exists in this module
  # @return [nil] if such as `Module` is not defined.
  def metasploit_module
    unless instance_variable_defined? :@metasploit_module
      @metasploit_module = nil
      # don't search ancestors for the metasploit module
      inherit = false

      maximum_version.downto(1) do |major|
        metasploit_constant_name = "Metasploit#{major}"

        if module_namespace.const_defined?(metasploit_constant_name, inherit)
          metasploit_constant = module_namespace.const_get(metasploit_constant_name)

          # Classes and Modules are Modules
          if metasploit_constant.is_a? Module
            @metasploit_module = metasploit_constant
            @metasploit_module.extend Metasploit::Cache::Module::Ancestor::Cacheable
          end

          break
        end
      end
    end

    @metasploit_module
  end

  def minimum_api_version
    required_versions[1]
  end

  def minimum_core_version
    required_versions[0]
  end

  # Evaluates `module_ancestor`'s `Metasploit::Model::Module::Ancestor` in the lexical scope of the `Module` in which
  # this module is `extend`ed.
  #
  # @param module_ancestor [Metasploit::Model::Module::Ancestor, #contents, #real_path]
  # @return [true] if `module_ancestor` was successfully evaluated into this namespace module.
  # @return [false] otherwise.
  def module_ancestor_eval(module_ancestor)
    success = false

    begin
      module_namespace.module_eval_with_lexical_scope(module_ancestor.contents, module_ancestor.real_path)
    rescue Interrupt
      # handle Interrupt as pass-through unlike other Exceptions so users can bail with Ctrl+C
      raise
    rescue Exception => exception
      @module_ancestor_eval_exception = exception
    else
      if valid?
        metasploit_module.cache.logger = logger
        metasploit_module.cache.persist(to: module_ancestor)

        # TODO log module_ancestor.errors
        if module_ancestor.persisted?
          success = true
        end
      end
    end

    success
  end

  def required_versions
    unless instance_variable_defined? :@required_versions
      if module_namespace.const_defined?(:RequiredVersions)
        @required_versions = module_namespace.const_get(:RequiredVersions)
      else
        @required_versions = [nil, nil]
      end
    end

    @required_versions
  end

  private

  def module_ancestor_eval_valid
    if module_ancestor_eval_exception
      errors.add(
          :module_ancestor_eval,
          "#{module_ancestor_eval_exception.class} #{module_ancestor_eval_exception}:\n" \
          "#{module_ancestor_eval_exception.backtrace.join("\n")}"
      )
    end
  end

  # Validates that {#metasploit_module} is usable on this local platform, but only if {#metasploit_module} is not `nil`.
  #
  # @return [void]
  def metasploit_module_usable
    if metasploit_module && metasploit_module.respond_to?(:is_usable) && !metasploit_module.is_usable
      errors.add(:metasploit_module, :unusable)
    end
  end
end