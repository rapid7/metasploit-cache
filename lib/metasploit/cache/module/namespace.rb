# Concerns namespace that wraps the ruby `Module` in `Metasploit::Model::Module::Ancestor#contents`
module Metasploit::Cache::Module::Namespace
  extend ActiveSupport::Autoload

  autoload :Cache
  autoload :Cacheable
  autoload :Load
  autoload :Loadable

  #
  # CONSTANTS
  #

  # Path for {CONTENT} evaluation so that errors are reported correctly.
  CONTENT_FILE = __FILE__
  # This must calculate the first line of the NAMESPACE_MODULE_CONTENT string so that errors are reported correctly
  CONTENT_LINE = __LINE__ + 4
  # By calling module_eval inside of module_eval_with_lexical_scope in the namespace module's body, the lexical scope
  # is captured and available to the code passed to module_eval_with_lexical_scope.
  CONTENT = <<-EOS.strip_heredoc.freeze
    extend Metasploit::Cache::Module::Namespace::Cacheable
    extend Metasploit::Cache::Module::Namespace::Loadable

    #
    # Module Methods
    #

    # Calls `Module#module_eval` on the `module_ancestor_contents`, but the lexical scope of the namespace_module is
    # passed through module_eval, so that `module_ancestor_contents` can act like it was written inline in the
    # namespace_module.
    #
    # @param module_ancestor_contents [String] {Metasploit::Cache::Module::Ancestor#contents}
    # @param module_ancestor_real_path [String] The path to the `Module`, so that error messages in evaluating
    #   `module_ancestor_contents` can be reported correctly.
    def self.module_eval_with_lexical_scope(module_ancestor_contents, module_ancestor_real_path)
      # By calling module_eval from inside the module definition, the lexical scope is captured and available to the
      # code in `module_ancestor_contents`.
      module_eval(module_ancestor_contents, module_ancestor_real_path)
    end
  EOS
  # @note The namespace must start with `Msf` as some modules in metasploit-framework do not fully-qualify their
  # constant names and are dependant on the loader leaking the `Msf` lexical scope.
  #
  # The base namespace name under which {create namespace modules are created}.
  NAMES = ['Msf', 'Modules']

  #
  # Attributes
  #

  # @!attribute [r] module_ancestor_eval_exception
  #   Exception raised in {#module_ancestor_eval}.
  #
  #   @return [nil] if {#module_ancestor_eval} has not run yet.
  #   @return [nil] if no exception was raised
  #   @return [Exception] if exception was raised
  attr_reader :module_ancestor_eval_exception

  # @!attribute [rw] module_type
  #   The `Metasploit::Model::Module::Ancestor#module_type`.
  #
  #   @return [String] element of `Metasploit::Model::Module::Type::ALL`.
  attr_accessor :module_type

  # @!attribute [rw] payload_type
  #   The `Metasploit::Model::Module::Ancestor#payload_type`.  Only set if {#module_type} is
  #   `Metasploit::Model::Module::Type::PAYLOAD`.
  #
  #   @return [nil] if {#module_type} is `Metasploit::Model::Module::Type::PAYLOAD`.
  #   @return [String] element of `Metasploit::Model::Module::Ancestor::PAYLOAD_TYPES`
  attr_accessor :payload_type

  # @!attribute [rw] real_path_sha1_hex_digest
  #   The `Metasploit::Model::Module::Ancestor#real_path_sha1_hex_digest`.  Used to look up
  #   `Metasploit::Module::Module::Ancestor`.
  #
  #   @return [String]
  attr_accessor :real_path_sha1_hex_digest

  #
  # Module Methods
  #

  # Returns a nested `Module` to wrap the Metasploit<n> `Module` so that it doesn't overwrite other (metasploit)
  # module's `Module`s.  The wrapper `Module` must be named so that active_support's autoloading code doesn't break when
  # searching constants from inside the `Metasploit<n>` `Module`.
  #
  # @param names [Array<String>] {names}
  # @return [Module, #module_eval_with_lexical_scope] `Module` that can wrap
  #   `Metasploit::Model::Module::Ancestor#contents` using `#module_eval_with_lexical_scope`.
  #
  # @see NAMESPACE_MODULE_CONTENT
  def self.create(names)
    # In order to have constants defined in {Msf} resolve without the {Msf} qualifier in the module_content, the
    # Module.nesting must resolve for the entire nesting.  Module.nesting is strictly lexical, and can't be faked with
    # module_eval(&block). (There's actually code in ruby's implementation to stop module_eval from being added to
    # Module.nesting when using the block syntax.) All this means is the modules have to be declared as a string that
    # gets module_eval'd.

    nested_names = names.reverse

    content = nested_names.inject(CONTENT) { |wrapped_content, module_name|
      lines = []
      lines << "module #{module_name}"
      lines << wrapped_content
      lines << "end"

      lines.join("\n")
    }

    # - because the added wrap lines have to act like they were written before NAMESPACE_MODULE_CONTENT
    line_with_wrapping = CONTENT_LINE - nested_names.length
    Object.module_eval(content, CONTENT_FILE, line_with_wrapping)

    # The namespace_module exists now, so no need to use constantize to do const_missing
    namespace_module = Metasploit::Cache::Constant.current(names)

    namespace_module
  end

  # Returns an Array of names to make a fully qualified module name to wrap the Metasploit<n> class so that it
  # doesn't overwrite other (metasploit) module's `Modules`.
  #
  # @param module_ancestor [Metasploit::Model::Module::Ancestor] The `Metasploit::Model::Module::Ancestor` whose
  #   `Metasploit::Model::Module::Ancestor#contents` will be evaluated inside the nested `module` declarations of
  #   this array of `Module#name`s.
  # @return [Array<String>] {NAMES} + <derived-constant-safe names>
  #
  # @see namespace_module
  def self.names(module_ancestor)
    NAMES + ["RealPathSha1HexDigest#{module_ancestor.real_path_sha1_hex_digest}"]
  end

  # Restores the namespace `Module` to it's original name under it's original parent `Module` if there was a previous
  # namespace `Module`.
  #
  # @param parent_module [Module] The `#parent` of `namespace_module` before it was removed from the constant tree.
  # @param relative_name [String] The name of the constant under `parent_module` where `namespace_module` was attached.
  # @param namespace_module [Module, nil] The previous namespace `Module` containing the old `Module` content.  If
  #   `nil`, then the `relative_name` constant is removed from `parent_module`, but nothing is set as the new constant.
  # @return [void]
  def self.restore(parent_module, relative_name, namespace_module)
    if parent_module
      inherit = false

      # If there is a current module with relative_name
      if parent_module.const_defined?(relative_name, inherit)
        # if the current value isn't the value to be restored.
        if parent_module.const_get(relative_name, inherit) != namespace_module
          # remove_const is private, so use send to bypass
          parent_module.send(:remove_const, relative_name)

          # if there was a previous module, not set it to the name
          if namespace_module
            parent_module.const_set(relative_name, namespace_module)
          end
        end
      else
        # if there was a previous module, but there isn't a current module, then restore the previous module
        if namespace_module
          parent_module.const_set(relative_name, namespace_module)
        end
      end
    end
  end

  # Creates a new namespace `Module` for `module_ancestor`'s `Metasploit::Model::Module::Ancestor#contents` to be
  # evaluated within.  If there was a previous module with the same name, then it is moved aside and restored if
  # the `Metasploit::Model::Module::Ancestor#contents` are invalid.
  #
  # @example Load `Metasploit::Model::Module::Ancestor#contents` without error handling
  #   namespace_module_transaction(module_ancestor) do |
  #
  # @param module_ancestor [Metasploit::Model::Module::Ancestor]
  # @yield [module_ancestor, namespace_module]
  # @yieldparam module_ancestor [Metasploit::Model::Module::Ancestor] `module_ancestor` argument to method.  Passed to
  #   block so that block can be a method reference like `&:method`.
  # @yieldparam namespace_module [Module, #module_eval_with_lexical_scope] Module in which to evaluate
  #   [Metasploit::Model::Module::Ancestor#contents]
  # @yieldreturn [true] to keep new namespace module.
  # @yieldreturn [false] to restore old namespace module.
  # @return [Boolean] yield return.
  def self.transaction(module_ancestor, &block)
    namespace_module_names = self.names(module_ancestor)

    previous_namespace_module = Metasploit::Cache::Constant.remove(namespace_module_names)
    relative_name = namespace_module_names.last

    namespace_module = create(namespace_module_names)

    # Set metadata from module_ancestor that is required for metasploit_module methods
    cache = namespace_module.cache
    cache.module_type = module_ancestor.module_type
    # record directly so it doesn't have to be derived from namespace_module.name
    cache.real_path_sha1_hex_digest = module_ancestor.real_path_sha1_hex_digest

    # Get the parent module from the created module so that
    # restore can remove namespace_module's constant if
    # needed.
    parent_module = namespace_module.parent

    begin
      commit = block.call(module_ancestor, namespace_module)
    rescue Exception
      restore(parent_module, relative_name, previous_namespace_module)

      # re-raise the original exception in the original context
      raise
    else
      unless commit
        restore(parent_module, relative_name, previous_namespace_module)
      end

      commit
    end
  end
end