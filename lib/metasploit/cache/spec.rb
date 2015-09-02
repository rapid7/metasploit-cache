# Helper methods for running specs for metasploit-cache.
module Metasploit::Cache::Spec
  extend ActiveSupport::Autoload

  autoload :Matcher
  autoload :Unload

  #
  # Module Methods
  #

  # A stream of samples of the given population.
  #
  # @param population [Array] array of objects to sample
  # @return [Enumerator] returns a sample each time it is iterated
  def self.sample_stream(population)
    Enumerator.new do |yielder|
      loop do
        yielder.yield population.sample
      end
    end
  end
end
