# Monitor constants created by module loading to ensure that the loads in one example don't interfere with the
# assertions in another example.
module Metasploit::Cache::Spec::Unload
  extend ActiveSupport::Autoload

  autoload :Each
  autoload :Suite

  #
  # CONSTANTS
  #

  # Regex parsing loaded module constants
  LOADED_MODULE_CHILD_CONSTANT_REGEXP = /^RealPathSha1HexDigest(?<real_path_sha1_hex_digest>[0-9a-f]+)$/
  # Constant names under {each_parent_constant} that can persist between specs because they are part of the loader
  # library and not dynamically loaded code
  PERSISTENT_CHILD_CONSTANT_NAMES = %w{
    Error
    Loader
    MetasploitClassCompatibilityError
    Namespace
    VersionCompatibilityError
  }.map(&:to_sym)

  # Adds actions to `spec` task so that `rake spec` fails if any of the following:
  #
  # # `log/leaked-constants.log` exists after printing out the leaked constants.
  # # {Each.configure!} is unnecessary in `spec/spec_helper.rb` and should be removed.
  #
  # @return [void]
  def self.define_task
    Suite.define_task
    # After Suite as Suite will kill for leaks before Each say it cleaned no leaks in case there are leaks in an
    # `after(:all)` that {Each} won't catch in its `after(:each)` checks.
    Each.define_task
  end

  # Yields each child_constant_name under {each_parent_constant}.
  #
  # @yield [parent_constant, child_name]
  # @yieldparam parent_constant (see each_parent_constant)
  # @yieldparam child_name [Symbol] name of child_constant_name relative to `parent_constant`.
  # @yieldreturn [void]
  # @return [Hash{Module => Integer}] Maps parent constant to number of constants leaked under that parent constant.
  #   There will be no entry for parent constant if it has not leaked constants.
  def self.each
    inherit = false
    count_by_parent_constant = {}

    each_parent_constant do |parent_constant|
      child_constant_names = parent_constant.constants(inherit)
      count = 0

      child_constant_names.each do |child_constant_name|
        unless PERSISTENT_CHILD_CONSTANT_NAMES.include? child_constant_name
          count += 1
          yield parent_constant, child_constant_name
        end
      end

      if count > 0
        count_by_parent_constant[parent_constant] = count
      end
    end

    count_by_parent_constant
  end

  # Yields each parent constant that is defined.
  #
  # @yield [parent_constant]
  # @yieldparam parent_constant [Module] a `Module` that is a namespace for Metasploit Module loading.
  # @yieldreturn [void]
  # @return [void]
  def self.each_parent_constant
    # Assume Metasploit::Cache is defined because it's a parent namespace of this Module.
    # Walk down tree towards actual parent constant to prevent loading of ancestors.
    if defined?(Metasploit::Cache::Payload)
      if defined?(Metasploit::Cache::Payload::Handler)
        if defined?(Metasploit::Cache::Payload::Handler::Namespace)
          yield Metasploit::Cache::Payload::Handler::Namespace
        end
      end
    end

    if defined?(Msf)
      if defined?(Msf::Modules)
        yield Msf::Modules
      end

      if defined?(Msf::Payloads)
        yield Msf::Payloads
      end
    end
  end

  # Unloads {each} child constant.
  #
  # @return [true] if there were leaked constants that were unloaded.
  # @return [false] if there were no leaked constants.
  # @see each
  def self.unload
    count = each do |parent_constant, child_name|
      parent_constant.send(:remove_const, child_name)
    end

    count != 0
  end
end