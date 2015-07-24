# Helpers for `Metasploit::Cache::*::AncestorCell`s
module Metasploit::Cache::AncestorCell
  # Enumerates `enumerable` giving `separator` for each element except the last so that comma separated lists can be
  # rendered more easily
  #
  # @example separate actions to form a ruby array
  #     [
  #     <%- separate(actions, ',') do |action, separator| -%>
  #       OpenStruct.new(name: '<%= action.name %>')<%= separator %>
  #     <%- end -%>
  #     ]
  #
  # @param enumerable [Enumerable, #length, #each_with_index]
  # @param separator [String] separator to yield for every element except the last
  # @yield [element, element_separator]
  # @yieldparam element [Object] element of `enumerable`.
  # @yieldparam element_separator [String] `separator` if `element` is not the last element; otherwise, `''`
  # @yieldreturn [void]
  # @return [void]
  def separate(enumerable, separator)
    last_index = enumerable.length - 1

    enumerable.each_with_index do |element, index|
      if index == last_index
        element_separator = ''.freeze
      else
        element_separator = separator
      end

      yield element, element_separator
    end
  end
end