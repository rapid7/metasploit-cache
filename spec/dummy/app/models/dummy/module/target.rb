# Implementation of {Metasploit::Cache::Module::Target} to allow testing of {Metasploit::Cache::Module::Target}
# using an in-memory ActiveModel and use of factories.
class Dummy::Module::Target < Metasploit::Model::Base
  include Metasploit::Cache::Module::Target

  #
  # Associations
  #


  # @!attribute [r] architectures
  #   Architectures that this target supports, either by being declared specifically for this target or because
  #   this target did not override architectures and so inheritted the architecture set from the class.
  #
  #   @return [Array<Metasploit::Cache::Architecture>]
  def architectures
    target_architectures.map(&:architecture)
  end

  # @!attribute [rw] module_instance
  #   Module where this target was declared.
  #
  #   @return [Dummy::Module::Instance]
  attr_accessor :module_instance

  # @!attribute [r] platforms
  #   Platforms that this target supports, either by being declared specifically for this target or because this
  #   target did not override platforms and so inheritted the platform set from the class.
  #
  #   @return [Array<Metasploit::Cache::Platform>]
  def platforms
    target_platforms.map(&:platform)
  end

  # @!attribute [rw] target_architectures
  #   Joins this target to its {#architectures}
  #
  #   @return [Array<Metasploit::Cache::Module::Target::Architecture]
  def target_architectures
    @target_architectures ||= []
  end
  attr_writer :target_architectures

  # @!attribute [rw] target_platforms
  #   Joins this target to its {#platforms}
  #
  #   @return [Array<Metasploit::Cache::Module::Target::Platform>]
  def target_platforms
    @target_platforms ||= []
  end
  attr_writer :target_platforms

  #
  # Attributes
  #

  # @!attribute [rw] name
  #   The name of this target.
  #
  #   @return [String]
  attr_accessor :name
end
