# Helpers to swapping nested constants.
module Metasploit::Cache::Constant
  # Return the constant with `names` if it exists.
  #
  # @param [Array<String>] names a list of constant names to resolve from `Object` downward.
  # @return [Object] the current value of the constant with `names`.
  # @return [nil] if no constant has `names`.
  def self.current(names)
    inject(names) {
      break
    }
  end

  # Yields each `parent` constant along with the `name` in `names` that is relative to that parent.
  #
  # @yield [parent, relative_name]
  # @yieldparam parent [Object] the current parent constant, normally a `Module`.
  # @yieldparam name [Object] the name of the constant under `parent` that should be returned from the block.
  # @yieldreturn [Object] the new value of `parent` for the next call of the block if `name` is not defined under
  #   `parent`.
  def self.inject(names)
    # don't look at ancestor constant for faster `const_defined?` calls
    inherit = false

    names.inject(Object) { |parent, name|
      if parent.const_defined?(name, inherit)
        parent.const_get(name)
      else
        yield parent, name
      end
    }
  end

  # Set name of constant.
  #
  # @param constant [Module]
  # @return [nil] There was no pre-existing constant with the same `names`.
  # @return [Object] The pre-existing constant with the same `names` that was replaced.
  def self.name(constant:, names:)
    parent_names = names[0 ... -1]
    relative_name = names[-1]

    parent = current(parent_names)

    if parent.nil?
      parent = inject(parent_names) { |current_parent, current_relative_name|
        current_parent.const_set(current_relative_name, Module.new)
      }
    end

    Metasploit::Cache::Constant.swap_on_parent(
        constant: constant,
        parent: parent,
        relative_name: relative_name
    )
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