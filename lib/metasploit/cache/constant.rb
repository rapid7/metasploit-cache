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

  # Swaps the constant with `relative_name` under `parent` with the given `constant`.
  #
  # @param parent [Module, #const_defined?, #const_get, #remove_const] The parent of `constant`.
  # @param relative_name [String] The name of the constant under `parent` where `constant` should be attached.
  # @param constant [Object, nil] The new value of `relative_name` under `parent`.  If `nil`, then the `relative_name`
  #   constant is removed from `parent_module`, but nothing is set as the new constant.
  # @return [Object] Previous value of `relative_name` constant under `parent`.
  def self.swap_on_parent(constant:, parent:, relative_name:)
    inherit = false

    # If there is a current constant with relative_name
    if parent.const_defined?(relative_name, inherit)
      # if the current value isn't the value to be swapped.
      if parent.const_get(relative_name, inherit) != constant
        # remove_const is private, so use send to bypass
        previous_constant = parent.send(:remove_const, relative_name)

        # if constant is set, now set it to the name
        if constant
          parent.const_set(relative_name, constant)
        end
      else
        previous_constant = constant
      end
    else
      previous_constant = nil

      # if there is new `constant`, but there isn't a current constant, then just set `constant`
      if constant
        parent.const_set(relative_name, constant)
      end
    end

    previous_constant
  end
end