# Writes templates for the {#direct_class #direct_class's} {Metasploit::Cache::Direct::Class#ancestor} to disk.
#
# @example Update files after changing associations
#   direct_class_factory = FactoryGirl.generate :metasploit_cache_direct_class_factory
#   direct_class = FactoryGirl.build(
#     direct_class_factory
#   )
#   # factory already wrote template when build returned
#
#   # update associations
#   rank = FactoryGirl.generate :metasploit_cache_rank
#   direct_class.rank = rank
#
#   # Now the template on disk is different than the `direct_class`, so regenerate the template
#   Metasploit::Cache::Direct::Class::Spec::Template.write(direct_class: direct_class)
class Metasploit::Cache::Direct::Class::Spec::Template < Metasploit::Model::Base
  extend Metasploit::Cache::Spec::Template::Write

  #
  # Attributes
  #

  # @!attribute direct_class
  #   The {Metasploit::Cache::Direct::Class} whose {Metasploit::Cache::Direct::Class#ancestor} needs to be templated in
  #   {#ancestor_template}.
  #
  #   @return [Metasploit::Cache::Direct::Class]
  attr_accessor :direct_class

  #
  # Validations
  #

  validates :direct_class,
            presence: true
  validate :ancestor_template_valid

  #
  # Methods
  #

  # Template for {#direct_class} {Metasploit::Cache::Direct::Class#ancestor} with the addition of {#direct_class} to
  # the {Metasploit::Cache::Spec::Template#locals} and adding 'direct/classes' to the front of the
  # {Metasploit::Cache::Spec::Template#search_pathnames}.
  #
  # @return [Array<Metasploit::Cache::Module::Ancestor::Spec::Template>]
  # @return [[]] if {#direct_class} is `nil`.
  def ancestor_template
    unless instance_variable_defined? :@ancestor_template
      if direct_class
        @ancestor_template = Metasploit::Cache::Module::Ancestor::Spec::Template.new(
            module_ancestor: direct_class.ancestor
        ).tap { |module_ancestor_template|
          module_ancestor_template.locals[:direct_class] = direct_class
          module_ancestor_template.overwrite = true

          module_ancestor_template.search_pathnames.unshift(
              Pathname.new('direct/classes')
          )
        }
      end
    end

    @ancestor_template
  end

  # Write {#ancestor_template} to disk.
  #
  # @return [void]
  # @raise (see Metasploit::Cache::Spec::Template)
  def write
    ancestor_template.write
  end

  private

  # Validates that all {#ancestor_template} is valid.
  #
  # @return [void]
  def ancestor_template_valid
    unless ancestor_template.valid?
      errors.add(:ancestor_template, :invalid, value: ancestor_template)
    end
  end

  Metasploit::Concern.run(self)
end