# Helpers to swapping nested constants.
module Metasploit::Cache::Constant
  # Return the constant with `names` if it exists.
  #
  # @param [Array<String>] names a list of constant names to resolve from `Object` downward.
  # @return [Object] the current value of the constant with `names`.
  # @return [nil] if no constant has `names`.
  def self.current(names)
    # dont' look at ancestor for constant for faster const_defined? calls.
    inherit = false

    # Don't want to trigger ActiveSupport's const_missing, so can't use constantize.
    named_constant = names.inject(Object) { |parent, name|
      if parent.const_defined?(name, inherit)
        parent.const_get(name)
      else
        break
      end
    }

    named_constant
  end

  # Remove the constant with `names` from its parent if it exists.
  #
  # @param names (see current)
  # @return [Object] the removed value of the constant with `names`.
  # @return [nil] if no constant has `names`.
  def self.remove(names)
    removable_constant = current(names)

    if removable_constant
      parent_module = removable_constant.parent
      relative_name = names.last
      # remove_const is private, so use send to bypass
      parent_module.send(:remove_const, relative_name)
    end

    removable_constant
  end
end