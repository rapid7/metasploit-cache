# Monitor constants created by module loading to ensure that the loads in one example don't interfere with the
# assertions in another example.
module Metasploit::Cache::Module::Ancestor::Spec::Unload
  extend ActiveSupport::Autoload

  autoload :Each
  autoload :Suite

  #
  # CONSTANTS
  #

  # Regex parsing loaded module constants
  LOADED_MODULE_CHILD_CONSTANT_REGEXP = /^RealPathSha1HexDigest(?<real_path_sha1_hex_digest>[0-9a-f]+)$/
  # Constant names under {parent_constant} that can persist between specs because they are part of the loader library
  # and not dynamically loaded code
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

  # Yields each child_constant_name under {parent_constant}.
  #
  # @yield [child_name]
  # @yieldparam child_name [Symbol] name of child_constant_name relative to {parent_constant}.
  # @yieldreturn [void]
  # @return [Integer] count
  def self.each
    inherit = false
    count = 0

    child_constant_names = parent_constant.constants(inherit)

    child_constant_names.each do |child_constant_name|
      unless PERSISTENT_CHILD_CONSTANT_NAMES.include? child_constant_name
        count += 1
        yield child_constant_name
      end
    end

    count
  end

  # @return [#constants, #remove_const]
  def self.parent_constant
    if defined?(Msf) && defined?(Msf::Modules)
      Msf::Modules
    else
      Module.new
    end
  end

  # Unloads child constants from {parent_constant}.
  #
  # @return [true] if there were leaked constants that were unloaded.
  # @return [false] if there were no leaked constants.
  # @see each
  def self.unload
    count = each do |child_name|
      parent_constant.send(:remove_const, child_name)
    end

    count != 0
  end
end