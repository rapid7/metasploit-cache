#
# Gems
#

require 'file/find'

# Stores the load paths used by Msf::ModuleManager#add_module_path (with symbolic {#name names}) so that the module path
# directories can be moved, but the cached metadata in {Metasploit::Cache::Module::Ancestor} and its associations can remain valid by
# just changing the Metasploit::Cache::Module::Path records in the database.
class Metasploit::Cache::Module::Path < ActiveRecord::Base
  extend ActiveSupport::Autoload

  autoload :AssociationExtension

  include Metasploit::Cache::RealPathname
  include Metasploit::Model::NilifyBlanks
  include Metasploit::Model::Translation

  #
  # Associations
  #

  # The auxiliary ancestors that use this as a {Metasploit::Cache::Module::Ancestor#parent_path}.
  has_many :auxiliary_ancestors,
           class_name: 'Metasploit::Cache::Auxiliary::Ancestor',
           dependent: :destroy,
           extend: AssociationExtension,
           foreign_key: :parent_path_id,
           inverse_of: :parent_path

  # The encoder ancestors that use this as a {Metasploit::Cache::Module::Ancestor#parent_path}.
  has_many :encoder_ancestors,
           class_name: 'Metasploit::Cache::Encoder::Ancestor',
           dependent: :destroy,
           extend: AssociationExtension,
           foreign_key: :parent_path_id,
           inverse_of: :parent_path

  # The exploit ancestors that use this as a {Metasploit::Cache::Module::Ancestor#parent_path}.
  has_many :exploit_ancestors,
           class_name: 'Metasploit::Cache::Exploit::Ancestor',
           dependent: :destroy,
           extend: AssociationExtension,
           foreign_key: :parent_path_id,
           inverse_of: :parent_path

  # The nop ancestors that use this as a {Metasploit::Cache::Module::Ancestor#parent_path}.
  has_many :nop_ancestors,
           class_name: 'Metasploit::Cache::Nop::Ancestor',
           dependent: :destroy,
           extend: AssociationExtension,
           foreign_key: :parent_path_id,
           inverse_of: :parent_path

  # The single payload ancestors that use this as a {Metasploit::Cache::Module::Ancestor#parent_path}.
  has_many :single_payload_ancestors,
           class_name: 'Metasploit::Cache::Payload::Single::Ancestor',
           dependent: :destroy,
           extend: AssociationExtension,
           foreign_key: :parent_path_id,
           inverse_of: :parent_path

  # The stage payload ancestors that use this as a {Metasploit::Cache::Module::Ancestor#parent_path}.
  has_many :stage_payload_ancestors,
           class_name: 'Metasploit::Cache::Payload::Stage::Ancestor',
           dependent: :destroy,
           extend: AssociationExtension,
           foreign_key: :parent_path_id,
           inverse_of: :parent_path

  # The stager payload ancestors that use this as a {Metasploit::Cache::Module::Ancestor#parent_path}.
  has_many :stager_payload_ancestors,
           class_name: 'Metasploit::Cache::Payload::Stager::Ancestor',
           dependent: :destroy,
           extend: AssociationExtension,
           foreign_key: :parent_path_id,
           inverse_of: :parent_path

  # The post ancestors that use this as a {Metasploit::Cache::Module::Ancestor#parent_path}.
  has_many :post_ancestors,
           class_name: 'Metasploit::Cache::Post::Ancestor',
           dependent: :destroy,
           extend: AssociationExtension,
           foreign_key: :parent_path_id,
           inverse_of: :parent_path

  #
  # Attributes
  #

  # @!attribute gem
  #   The name of the gem that is adding this module path to metasploit-framework.  For paths normally added by
  #   metasploit-framework itself, this would be `'metasploit-framework'`, while for Metasploit Pro this would be
  #   `'metasploit-pro'`.  The name used for `gem` does not have to be a gem on rubygems, it just functions as a
  #   namespace for {#name} so that projects using metasploit-framework do not need to worry about collisions on
  #   {#name} which could disrupt the cache behavior.
  #
  #   @return [String]

  # @!attribute name
  #   The name of the module path scoped to {#gem}.  {#gem} and {#name} uniquely identify this path so that if
  #   {#real_path} changes, the entire cache does not need to be invalidated because the change in {#real_path} will
  #   still be tied to the same ({#gem}, {#name}) tuple.
  #
  #   @return [String]

  # @!attribute real_path
  #   @note Non-real paths will be converted to real paths in a before validation callback, so take care to either pass
  #   real paths or pay attention when setting {#real_path} and then changing directories before validating.
  #
  #   The real (absolute) path to module path.
  #
  #   @return [String]

  #
  # Callbacks - in calling order
  #

  nilify_blank :gem,
               :name
  before_validation :normalize_real_path

  #
  #
  # Validations
  #
  #

  #
  # Method validations
  #

  validate :directory
  validate :gem_and_name

  #
  # Attribute validations
  #

  validates :name,
            uniqueness: {
                allow_nil: true,
                scope: :gem,
                unless: :add_context?
            }
  validates :real_path,
            uniqueness: {
                unless: :add_context?
            }

  #
  # Class Methods
  #

  # Whether `gem` and `name` are a valid name tuple.
  #
  # @return [true] if `gem` and `name` are preesent.
  # @return [false] otherwise
  def self.named?(gem:, name:)
    gem.present? and name.present?
  end

  # Returns path with the same `gem` and `name`.
  #
  # @param gem [String, nil] {#gem} of new {Metasploit::Cache::Module::Path}.
  # @param name [String, nil] {#name} of new {Metasploit::Cache::Module::Path}.
  # @return [Metasploit::Cache::Module::Path] if there is a {Metasploit::Cache::Module::Path} with the same {#gem} and
  #   {#name} as `gem` and `name`.
  # @return [nil] unless `gem` and `name` are present.
  # @return [nil] if there is no match.
  def self.name_collision(gem:, name:)
    collision = nil

    if named?(gem: gem, name: name)
      collision = where(gem: gem, name: name).first
    end

    collision
  end

  # Returns path with teh same `real_path`.
  #
  # @param real_path [String] {#real_path} of new {Metasploit::Cache::Module::Path}.
  # @return [Metasploit::Cache::Module::Path] if there is a {Metasploit::Cache::Module::Path} with the same
  #   {#real_path} as `real_path`.
  # @return [nil] if there is no match.
  def self.real_path_collision(real_path)
    where(real_path: real_path).first
  end

  # Resolves conflicts with pre-existing {Metasploit::Cache::Module::Path}s.
  #
  # @return [Metasploit::Cache::Module::Path] new or updated path.
  def self.resolve_collisions(gem:, name:, real_path:)
    name_collision = name_collision(gem: gem, name: name)
    real_path_collision = real_path_collision(real_path)

    if name_collision and real_path_collision
      if name_collision != real_path_collision
        raise ActiveRecord::RecordNotUnique,
              "Collision against two pre-existing #{name.pluralize}: (1) on gem (#{name_collision.gem}) and name " \
              "(#{name_collision.name}) and (2) on real_path (#{real_path_collision.real_path})."
      end

      # collision is already path
      resolved = name_collision
    elsif name_collision
      # Update (real_path) as newer path is preferred.
      name_collision.real_path = real_path
      name_collision.save!

      resolved = name_collision
    elsif real_path_collision
      # prevent a named real_path_collision being replaced by an unnamed
      # new path as it is better for a real_path to have a (gem, name).
      if named?(gem: gem, name: name)
        real_path_collision.gem = gem
        real_path_collision.name = name
        real_path_collision.save!
      end

      resolved = real_path_collision
    else
      # New (gem, name) and real_path
      resolved = create!(gem: gem, name: name, real_path: real_path)
    end

    resolved
  end

  #
  # Instance Methods
  #

  # Returns whether {#real_path} is a directory.
  #
  # @return [true] if {#real_path} is a directory.
  # @return [false] if {#real_path} is not a directory.
  def directory?
    directory = false

    if real_path and File.directory?(real_path)
      directory = true
    end

    directory
  end

  # Returns whether is a named path.
  #
  # @return [false] if gem is blank or name is blank.
  # @return [true] if gem is not blank and name is not blank.
  def named?
    named = false

    if gem.present? and name.present?
      named = true
    end

    named
  end

  # Returns whether was a named path.  This is the equivalent of {#named?}, but checks the old, pre-change
  # values for {#gem} and {#name}.
  #
  # @return [false] is gem_was is blank or name_was is blank.
  # @return [true] if gem_was is not blank and name_was is not blank.
  def was_named?
    was_named = false

    if gem_was.present? and name_was.present?
      was_named = true
    end

    was_named
  end

  private

  # Returns whether #validation_context is `:add`.  If #validation_context is :add then the uniqueness validations on
  # :name and :real_path are skipped so that this path can be validated prior to looking for pre-existing
  # {Metasploit::Cache::Module::Path paths} with either the same {#real_path} that needs to have its {#gem} and {#name} updated
  # {Metasploit::Cache::Module::Path paths} with the same {#gem} and {#name} that needs to have its {#real_path} updated.
  #
  # @return [true] if uniqueness validations should be skipped.
  # @return [false] if normal create or update context.
  def add_context?
    if validation_context == :add
      true
    else
      false
    end
  end

  # Validates that either {#directory?} is `true`.
  #
  # @return [void]
  def directory
    unless directory?
      errors[:real_path] << 'must be a directory'
    end
  end

  # Validates that either both {#gem} and {#name} are present or both are `nil`.
  #
  # @return [void]
  def gem_and_name
    if name.present? and gem.blank?
      errors[:gem] << "can't be blank if name is present"
    end

    if gem.present? and name.blank?
      errors[:name] << "can't be blank if gem is present"
    end
  end

  # If {#real_path} is set and exists on disk, then converts it to a real path to eliminate any symlinks.
  #
  # @return [void]
  # @see Metasploit::Model::File.realpath
  def normalize_real_path
    if real_path and File.exist?(real_path)
      self.real_path = Metasploit::Model::File.realpath(real_path)
    end
  end

  # Switch back to public for load hooks
  public

  Metasploit::Concern.run(self)
end