module Metasploit::Cache::Direct::Class::Spec
  extend ActiveSupport::Autoload

  autoload :Template

  #
  # CONSTANTS
  #

  # Factories for {Metasploit::Cache::Direct::Class} subclasses
  FACTORIES = []

  #
  # Module Methods
  #

  # Streams of elements of {FACTORIES}
  #
  # @return [Enumerator<Symbol>]
  def self.random_factory
    Enumerator.new do |yielder|
      loop do
        yielder.yield FACTORIES.sample
      end
    end
  end
end