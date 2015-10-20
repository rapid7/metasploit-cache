# Tracks the number of runs of a context and limits the runs to a {#max} number.
# Must be an object as simple integers can only be updated when a context
# variable, which doesn't work for function calls
class Metasploit::Cache::Spec::RunCounter
  #
  # Attributes
  #

  # @return [Integer] the number of runs so far
  attr_accessor :count

  # @return [Integer] the maximum number of runs
  # @return [nil] no limit to the number of runs
  attr_accessor :max

  #
  # Initialize
  #

  # @param max [Integer, nil] The maximum number of runs.  `nil` for no limit.
  def initialize(max:)
    @count = 0
    @max = max
  end
end