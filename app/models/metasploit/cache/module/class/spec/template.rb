# Writes templates for the {#module_class #module_class's} {Metasploit::Cache::Module::Class#ancestors} to disk.
#
# @example Update files after changing associations
#   module_class = FactoryGirl.build(
#     :dummy_module_class
#   )
#   # factory already wrote template when build returned
#
#   # update associations
#   rank = FactoryGirl.generate :dummy_rank
#   module_class.rank = rank
#
#   # Now the template on disk is different than the module_class, so regenerate the template
#   Metasploit::Cache::Module::Class::Spec::Template.write(module_class: module_class)
class Metasploit::Cache::Module::Class::Spec::Template < Metasploit::Model::Base
  extend Metasploit::Cache::Spec::Template::Write

  #
  # Attributes
  #

  # @!attribute [rw] module_class
  #   The {Metasploit::Cache::Module::Class} whose {Metasploit::Cache::Module::Class#ancestors} need to be templated in
  #   {#ancestor_templates}.
  #
  #   @return [Metasploit::Cache::Module::Class]
  attr_accessor :module_class

  #
  # Validations
  #

  validates :module_class,
            presence: true
  validate :ancestor_templates_valid

  #
  # Methods
  #

  # Template for {#module_class} {Metasploit::Cache::Module::Class#ancestors} with the addition of {#module_class} to
  # the {Metasploit::Cache::Spec::Template#locals} and adding 'module/classes' to the front of the
  # {Metasploit::Cache::Spec::Template#search_pathnames}.
  #
  # @return [Array<Metasploit::Cache::Module::Ancestor::Spec::Template>]
  # @return [[]] if {#module_class} is `nil`.
  def ancestor_templates
    unless instance_variable_defined? :@ancestor_templates
      if module_class
        @ancestor_templates = module_class.ancestors.collect { |module_ancestor|
          Metasploit::Cache::Module::Ancestor::Spec::Template.new(
              module_ancestor: module_ancestor
          ).tap { |module_ancestor_template|
            module_ancestor_template.locals[:module_class] = module_class
            module_ancestor_template.overwrite = true

            module_ancestor_template.search_pathnames.unshift(
                Pathname.new('module/classes')
            )
          }
        }
      end

      @ancestor_templates ||= []
    end

    @ancestor_templates
  end

  # Writes {#ancestor_templates} to disk.
  #
  # @return [void]
  # @raise (see Metasploit::Cache::Spec::Template)
  def write
    ancestor_templates.each(&:write)
  end

  private

  # Validates that all {#ancestor_templates} are valid.
  #
  # @return [void]
  def ancestor_templates_valid
    # can't use ancestor_templates.all?(&:valid?) as it will short-circuit and want all ancestor_templates to have
    # validation errors
    valids = ancestor_templates.map(&:valid?)

    unless valids.all?
      errors.add(:ancestor_templates, :invalid, value: ancestor_templates)
    end
  end
end