#
# Gems
#

require 'file/find'

# Stores the load paths used by Msf::ModuleManager#add_module_path (with symbolic {#name names}) so that the module path
# directories can be moved, but the cached metadata in {Metasploit::Cache::Module::Ancestor} and its associations can remain valid by
# just changing the Metasploit::Cache::Module::Path records in the database.
class Metasploit::Cache::Module::Path < ActiveRecord::Base
  include Metasploit::Cache::RealPathname
  include Metasploit::Model::NilifyBlanks
  include Metasploit::Model::Translation

  #
  # Associations
  #

  # @!attribute module_ancestors
  #   The modules ancestors that use this as a {Metasploit::Cache::Module::Ancestor#parent_path}.
  #
  #   @return [ActiveRecord::Relation<Metasploit::Cache::Module::Ancestor>]
  has_many :module_ancestors,
           class_name: 'Metasploit::Cache::Module::Ancestor',
           dependent: :destroy,
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
  # Mass Assignment Security
  #

  attr_accessible :gem
  attr_accessible :name
  attr_accessible :real_path

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
            :uniqueness => {
                :allow_nil => true,
                :scope => :gem,
                :unless => :add_context?
            }
  validates :real_path,
            :uniqueness => {
                :unless => :add_context?
            }

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

  # @note The yielded {Metasploit::Cache::Module::Ancestor} may contain unsaved changes.  It is the responsibility of the caller to
  #   save the record.
  #
  # @overload each_changed_module_ancestor(options={}, &block)
  #   Yields each module ancestor that is changed under this module path.
  #
  #   @yield [module_ancestor]
  #   @yieldparam module_ancestor [Metasploit::Cache::Module::Ancestor] a changed, or in the case of `changed: true`,
  #     assumed changed, {Metasploit::Cache::Module::Ancestor}.
  #   @yieldreturn [void]
  #   @return [void]
  #
  # @overload each_changed_module_ancestor(options={})
  #   Returns enumerator that yields each module ancestor that is changed under this module path.
  #
  #   @return [Enumerator]
  #
  # @param options [Hash{Symbol => Boolean}]
  # @option options [Boolean] :changed (false) if `true`, assume the
  #   {Metasploit::Cache::Module::Ancestor#real_path_modified_at} and
  #   {Metasploit::Cache::Module::Ancestor#real_path_sha1_hex_digest} have changed and that
  #   {Metasploit::Cache::Module::Ancestor} should be returned.
  # @option options [ProgressBar, #total=, #increment] :progress_bar a ruby `ProgressBar` or similar object that
  #   supports the `#total=` and `#increment` API for monitoring the progress of the enumerator.  `#total` will be set
  #   to total number of {#module_ancestor_relative_paths relative paths} under this module path, not just the number of
  #   changed (updated or new) real paths.  `#increment` will be called whenever a relative path is visited, which means
  #   it can be called when there is no yielded module ancestor because that module ancestor was unchanged.  When
  #   {#each_changed_module_ancestor} returns, `#increment` will have been called the same number of times as the value
  #   passed to `#total=` and `#finished?` will be `true`.
  #
  # @see #changed_module_ancestor_from_relative_path
  def each_changed_module_ancestor(options={})
    options.assert_valid_keys(:changed, :progress_bar)

    unless block_given?
      to_enum(__method__, options)
    else
      relative_paths = module_ancestor_relative_paths

      progress_bar = options[:progress_bar] || Metasploit::Cache::NullProgressBar.new
      progress_bar.total = relative_paths.length

      # ensure the connection doesn't stay checked out for thread in metasploit-framework.
      ActiveRecord::Base.connection_pool.with_connection do
        updatable_module_ancestors = module_ancestors.where(relative_path: relative_paths)
        new_relative_path_set = Set.new(relative_paths)
        assume_changed = options.fetch(:changed, false)

        # use find_each since this is expected to exceed default batch size of 1000 records.
        updatable_module_ancestors.find_each do |updatable_module_ancestor|
          new_relative_path_set.delete(updatable_module_ancestor.relative_path)

          changed = assume_changed

          # real_path_modified_at and real_path_sha1_hex_digest should be updated even if assume_changed is true so
          # that database stays in-sync with file system

          updatable_module_ancestor.real_path_modified_at = updatable_module_ancestor.derived_real_path_modified_at

          # only derive the SHA1 Hex Digest if modification time has changed to save time
          if updatable_module_ancestor.real_path_modified_at_changed?
            updatable_module_ancestor.real_path_sha1_hex_digest = updatable_module_ancestor.derived_real_path_sha1_hex_digest

            changed ||= updatable_module_ancestor.real_path_sha1_hex_digest_changed?
          end

          if changed
            yield updatable_module_ancestor
            progress_bar.increment
          else
            # increment even when no yield so that increment occurs for each path and matches totally without jumps
            progress_bar.increment
          end
        end

        # after all pre-existing relative_paths are subtracted, new_relative_path_set contains only relative_paths not
        # in the database
        new_relative_path_set.each do |relative_path|
          new_module_ancestor = module_ancestors.new(relative_path: relative_path)

          yield new_module_ancestor
          progress_bar.increment
        end
      end
    end
  end

  # @!method gem=(gem)
  #   Sets {#gem}.
  #
  #   @param gem [String] The name of the gem that is adding this module path to metasploit-framework.  For paths
  #     normally added by metasploit-framework itself, this would be `'metasploit-framework'`, while for Metasploit Pro
  #     this would be `'metasploit-pro'`.  The name used for `gem` does not have to be a gem on rubygems, it just
  #     functions as a namespace for {#name} so that projects using metasploit-framework do not need to worry about
  #     collisions on {#name} which could disrupt the cache behavior.
  #   @return [void]

  # {Metasploit::Cache::Module::Ancestor#relative_path} under {#real_path} on-disk.
  #
  # @return [Array<String>]
  def module_ancestor_relative_paths
    real_pathname = self.real_pathname

    module_ancestor_rule.find.map { |module_ancestor_real_path|
      module_ancestor_real_pathname = Pathname.new(module_ancestor_real_path)
      relative_pathname = module_ancestor_real_pathname.relative_path_from(real_pathname)

      relative_pathname.to_path
    }
  end

  # File::Find rule for find all {Metasploit::Cache::Module::Ancestor#relative_path} under {#real_path} on-disk.
  #
  # @return [File::Find]
  def module_ancestor_rule
    File::Find.new(
        ftype: 'file',
        path: real_path,
        pattern: "*#{Metasploit::Cache::Module::Ancestor::EXTENSION}"
    )
  end

  # @!method module_ancestors=(module_ancestors)
  #   Sets {#module_ancestors}.
  #
  #   @param module_ancestors [Enumerable<Metasploit::Cache::Module::Ancestor>, nil] The modules ancestors that use
  #     this as a {Metasploit::Cache::Module::Ancestor#parent_path}.
  #   @return [void]

  # @note This path should be validated before calling {#name_collision} so that {#gem} and {#name} is normalized.
  #
  # Returns path with the same {#gem} and {#name}.
  #
  # @return [Metasploit::Cache::Module::Path] if there is a {Metasploit::Cache::Module::Path} with the same {#gem} and {#name} as this path.
  # @return [nil] if #named? is `false`.
  # @return [nil] if there is not match.
  def name_collision
    collision = nil

    # Don't query database if gem and name are `nil` since all unnamed paths will match.
    if named?
      collision = self.class.where(:gem => gem, :name => name).first
    end

    collision
  end

  # @!method name=(name)
  #   Sets {#name}.
  #
  #   @param name [String] The name of the module path scoped to {#gem}.  {#gem} and {#name} uniquely identify this
  #     path, so that if {#real_path} changes, the entire cache does not need to be invalidated because the change in
  #     {#real_path} will still be tied to the same ({#gem}, {#name}) tuple.
  #   @return [void]

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

  # @note This path should be validated before calling {#real_path_collision} so that {#real_path} is normalized.
  #
  # Returns path with the same {#real_path}.
  #
  # @return [Metasploit::Cache::Module::Path] if there is a {Metasploit::Cache::Module::Path} with the same {#real_path} as this path.
  # @return [nil] if there is not match.
  def real_path_collision
    self.class.where(:real_path => real_path).first
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

  # @!method real_path=(real_path)
  #   Sets {#real_path}.
  #
  #   @param real_path [String] The real (absolute) path to module path.
  #   @return [void]

  # Comment break to make {#real_path=} docs work above `private`

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