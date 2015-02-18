require 'weakref'

# Adds {#resurrecting_attr_accessor} DSL to extending `Module`.  Resurrecting attributes are held in weak references
# that can be garbage collected.  If the a resurrecting attribute has been garbage collected, then it is resurrected
# using the supplied block.  The block should use less memory-intensive attributes to return the original attribute from
# the block.
#
# @example Defining a resurrecting attribute
#   class Metasploit::Cache::Module::Ancestor::Cache
#     extend Metasploit::Cache::ResurrectingAttribute
#
#     #
#     # Attributes
#     #
#
#     # The SHA1 hexdigest of the path where the Metasploti Module is defined on disk.
#     #
#     # @return [String]
#     attr_accessor :real_path_sha1_hex_digest
#
#     #
#     # Resurrecting Attributes
#     #
#
#     resurrecting_attr_accessor :module_ancestor do
#        ActiveRecord::Base.connection_pool.with_connection {
#          Metasploit::Cache::Module::Ancestor.where(real_path_sha1_hex_digest: real_path_sha1_hex_digest).first
#        }
#      end
#   end
module Metasploit::Cache::ResurrectingAttribute
  # Defines a reader and writer for `attribute_name`.
  #
  # Resurrecting attributes are held in weak references that can be garbage collected.  If the a resurrecting attribute
  # has been garbage collected, then it is resurrected using the supplied block.  The block should use less
  # memory-intensive attributes to return the original attribute from the block.
  #
  # @param attribute_name [Symbol] name of the attribute.
  # @yield Block called when attribute value has been garbage collected and `attribute_name` reader is called.
  # @yieldreturn [Object] Strong reference to be returned from `attribute_name` reader and to be stored weakly for later
  #   use.
  def resurrecting_attr_accessor(attribute_name, &block)
    instance_variable_name = "@#{attribute_name}".to_sym
    getter_name = attribute_name
    setter_name = "#{attribute_name}="

    define_method(getter_name) do
      begin
        strong_reference = nil
        weak_reference = instance_variable_get instance_variable_name

        if weak_reference
          strong_reference = weak_reference.__getobj__
        else
          strong_reference = instance_exec(&block)

          send(setter_name, strong_reference)
        end
      rescue WeakRef::RefError
        # try again by rebuild because __getobj__ failed on the weak_reference because the referenced object was garbage
        # collected.
        instance_variable_set instance_variable_name, nil

        retry
      end

      # Return strong reference so consuming code doesn't have to handle the weak_reference being garbase collected.
      strong_reference
    end

    define_method(setter_name) do |strong_reference|
      unless strong_reference.nil?
        weak_reference = WeakRef.new(strong_reference)
      else
        weak_reference = strong_reference
      end

      instance_variable_set instance_variable_name, weak_reference

      # don't return the WeakRef as the use of WeakRefs is an implementation detail and __getobj__ failure hiding is the
      # purpose of the reader.
      strong_reference
    end
  end
end