require 'digest/sha1'

# Module metadata that can be derived from a loaded module, which is an ancestor, in the sense of ruby's
# Module#ancestor, or a metasploit module class, Class<Msf::Module>.  Loaded modules will be either a ruby Module
# (for payloads) or a ruby Class (for all non-payloads).
class Metasploit::Cache::Module::Ancestor < ActiveRecord::Base
  extend ActiveSupport::Autoload

  include Metasploit::Cache::Batch::Descendant
  include Metasploit::Cache::Batch::Root
  include Metasploit::Cache::Derivation
  include Metasploit::Cache::Derivation::FullName
  include Metasploit::Model::Translation

  autoload :Cache
  autoload :Cacheable
  autoload :Load
  autoload :Spec

  #
  # CONSTANTS
  #

  # The directory for a given {#module_type} is a not always the pluralization of {#module_type}.
  DIRECTORY_BY_MODULE_TYPE = {
      Metasploit::Cache::Module::Type::AUX => Metasploit::Cache::Module::Type::AUX,
      Metasploit::Cache::Module::Type::ENCODER => Metasploit::Cache::Module::Type::ENCODER.pluralize,
      Metasploit::Cache::Module::Type::EXPLOIT => Metasploit::Cache::Module::Type::EXPLOIT.pluralize,
      Metasploit::Cache::Module::Type::NOP => Metasploit::Cache::Module::Type::NOP.pluralize,
      Metasploit::Cache::Module::Type::PAYLOAD => Metasploit::Cache::Module::Type::PAYLOAD.pluralize,
      Metasploit::Cache::Module::Type::POST => Metasploit::Cache::Module::Type::POST
  }

  # File extension used for metasploit modules.
  EXTENSION = '.rb'

  # Maps directory to {#module_type} for converting a {#relative_path} into a {#module_type} and {#reference_name}
  MODULE_TYPE_BY_DIRECTORY = DIRECTORY_BY_MODULE_TYPE.invert

  # Separator used to join names in {#reference_name}.  It is always '/', even on Windows, where '\' is a valid
  # file separator.
  REFERENCE_NAME_SEPARATOR = '/'

  # Regular expression matching a full SHA-1 hex digest.
  SHA1_HEX_DIGEST_REGEXP = /\A[0-9a-z]{40}\Z/

  #
  #
  # Associations
  #
  #

  # Relates this {Metasploit::Cache::Module::Ancestor} to the
  # {Metasploit::Cache::Module::Class Metasploit::Cache::Module::Classes} that
  # {Metasploit::Cache::Module::Relationship#descendant descend} from the {Metasploit::Cache::Module::Ancestor}.
  has_many :relationships, class_name: 'Metasploit::Cache::Module::Relationship', dependent: :destroy, inverse_of: :ancestor

  #
  # through: :relationships
  #

  # {Metasploit::Cache::Module::Class Classes} that either subclass the ruby Class in {#real_pathname} or include the
  # ruby Module in {#real_pathname}.
  has_many :descendants, class_name: 'Metasploit::Cache::Module::Class', through: :relationships

  #
  # Attributes
  #

  # @!attribute real_path_modified_at
  #   The modification time of the module {#real_pathname file on-disk}.
  #
  #   @return [DateTime]

  # @!attribute real_path_sha1_hex_digest
  #   The SHA1 hexadecimal digest of contents of the file at {#real_pathname}.  Stored as a string because postgres does
  #   not have support for a 160 bit numerical type and the hexdigest format is more recognizable when using SQL
  #   directly.
  #
  #   @see Digest::SHA1#hexdigest
  #   @return [String]

  # @!attribute relative_path
  #   The relative path under {#parent_path} {Metasploit::Cache::Module::Path#real_path} to the module file on-disk.
  #
  #   @return [String]

  #
  # Derivations
  #

  # Don't validate attributes that require accessing file system to derive value
  derives :real_path_modified_at, :validate => false
  derives :real_path_sha1_hex_digest, :validate => false

  #
  # Mass Assignment Security
  #

  # relative_path is accessible since it is set when building cache.
  attr_accessible :relative_path
  # real_path_modified_at is NOT accessible since it's derived
  # real_path_sha1_hex_digest is NOT accessible since it's derived

  #
  # Validations
  #

  validates :module_type,
            inclusion: {
                in: Metasploit::Cache::Module::Type::ALL
            }
  validates :parent_path,
            presence: true
  validates :real_path_modified_at,
            presence: true
  validates :real_path_sha1_hex_digest,
            format: {
                with: SHA1_HEX_DIGEST_REGEXP
            },
            uniqueness: {
                unless: :batched?
            }
  validates :relative_path,
            uniqueness: {
                unless: :batched?
            }

  #
  # Class Methods
  #

  # @note The yielded {Metasploit::Cache::Module::Ancestor} may contain unsaved changes.  It is the responsibility of
  #   the caller to save the record.
  #
  # @overload each_changed(assume_changed: false, progress_bar: Metasploit::Cache::NullProgressBar.new, relative_paths:, scope:)
  #   Yields each module ancestor that is changed on `relative_paths`.
  #
  #   @yield [module_ancestor]
  #   @yieldparam module_ancestor [Metasploit::Cache::Module::Ancestor] a changed, or in the case `assume_changed` is
  #     `true`, assumed changed, {Metasploit::Cache::Module::Ancestor}.
  #   @yieldreturn [void]
  #   @return [void]
  #
  # @overload each_changed(assume_changed: false, progress_bar: Metasploit::Cache::NullProgressBar.new, relative_paths:, scope:)
  #   Returns enumerator that yields each module ancestor that is changed under `relative_paths`.
  #
  #   @return [Enumerator<Metasploit::Cache::Module::Ancestor>]
  #
  # @param assume_changed [Boolean] if `true`, assume the {Metasploit::Cache::Module::Ancestor#real_path_modified_at}
  #   and {Metasploit::Cache::Module::Ancestor#real_path_sha1_hex_digest} have changed and that
  #   {Metasploit::Cache::Module::Ancestor} should be yielded.
  # @param progress_bar [ProgressBar, #total=, #increment] a ruby `ProgressBar` or similar object that supports the
  #   `#total=` and `#increment` API for monitoring the progress of the enumerator.  `#total` will be set to total
  #   number of `relative_paths`, not just the number of changed (updated or new) relative_paths.  `#increment` will be
  #   called whenever a relative path is visited, which means it can be called when there is no yielded module ancestor
  #   because that module ancestor was unchanged.  When {each_changed} returns, `#increment` will have been called the
  #   same number of times as the value passed to `#total=` and `#finished?` will be `true`.
  # @param relative_paths [Array<String>] an `Array` of {Metasploit::Cache::Module::Ancestor#real_path}.
  # @param scope [ActiveRecord::Relation<Class<Metasploit::Cache::Module::Ancestor>>] scope for a
  #   `Class<Metasploit::Cache::Module::Ancestor>`.
  def self.each_changed(assume_changed: false, progress_bar: Metasploit::Cache::NullProgressBar.new, relative_paths:, scope:)
    if block_given?
      progress_bar.total = relative_paths.length

      ActiveRecord::Base.connection_pool.with_connection do
        updatable_module_ancestors = scope.where(relative_path: relative_paths)
        new_relative_path_set = Set.new relative_paths

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
          new_module_ancestor = scope.new(relative_path: relative_path)

          yield new_module_ancestor
          progress_bar.increment
        end
      end
    else
      enum_for(
          __method__,
          assume_changed: assume_changed,
          progress_bar: progress_bar,
          relative_paths: relative_paths,
          scope: scope
      )
    end
  end

  # Ensure that only {#module_type} matching `MODULE_TYPE` is valid for `subclass`.
  #
  # @param subclass [Class<Metasploit::Cache::Module::Ancestor>] a subclass of {Metasploit::Cache::Module::Ancestor}.
  # @return [void]
  def self.restrict(subclass)
    #
    # Validations
    #

    subclass.validate :module_type_matches

    #
    # Class Methods
    #

    subclass_relative_path_prefix = "#{subclass::MODULE_TYPE_DIRECTORY}".freeze

    subclass.define_singleton_method(:relative_path_prefix) do
      subclass_relative_path_prefix
    end

    #
    # Instance Methods
    #

    error = "is not #{subclass::MODULE_TYPE}"

    subclass.send(:define_method, :module_type_matches) do
      if module_type != subclass::MODULE_TYPE
        errors.add(:module_type, error)
      end
    end

    subclass.send(:private, :module_type_matches)
  end

  #
  # Initialize
  #

  def initialize(*args)
    if self.class == Metasploit::Cache::Module::Ancestor
      raise TypeError,
            "Cannot directly instantiate a Metasploit::Cache::Module::Ancestor.  Create one of the subclasses:\n" \
            "* Metasploit::Cache::Auxiliary::Ancestor\n" \
            "* Metasploit::Cache::Encoder::Ancestor\n" \
            "* Metasploit::Cache::Exploit::Ancestor\n" \
            "* Metasploit::Cache::Nop::Ancestor\n" \
            "* Metasploit::Cache::Payload::Single::Ancestor\n" \
            "* Metasploit::Cache::Payload::Stage::Ancestor\n" \
            "* Metasploit::Cache::Payload::Stager::Ancestor\n" \
            "* Metasploit::Cache::Post::Ancestor"
    end

    super
  end

  #
  # Instance Methods
  #

  def batched?
    super || loading_context?
  end

  # The contents of {#real_pathname}.
  #
  # @return [String] contents of file at {#real_pathname}.
  # @return [nil] if {#real_pathname} is `nil`.
  # @return [nil] if {#real_pathname} does not exist on-disk.
  def contents
    contents = nil

    real_pathname = self.real_pathname

    if real_pathname
      # rescue around both File calls since file could be deleted before size or after size and before read
      begin
        size = real_pathname.size
        # Specify full size of file for faster read on Windows (less chance of context switching mid-read).
        # Open in binary mode in Windows to handle non-text content embedded in file.
        contents = real_pathname.read(size, 0, mode: 'rb')
      rescue Errno::ENOENT
        contents = nil
      end
    end

    contents
  end

  # Derives {#real_path_modified_at} by getting the modification time of the file on-disk.
  #
  # @return [Time] modification time of {#real_pathname} if {#real_pathname} exists on disk and modification time can be
  #   queried by user.
  # @return [nil] if {#real_pathname} does not exist or user cannot query the file's modification time.
  def derived_real_path_modified_at
    begin
      mtime = real_pathname.try(:mtime)
    rescue Errno::ENOENT
      nil
    else
      mtime.try(:utc)
    end
  end

  # Derives {#real_path_sha1_hex_digest} by running the contents of {#real_pathname} through Digest::SHA1.hexdigest.
  #
  # @return [String] 40 character SHA1 hex digest if {#real_pathname} can be read.
  # @return [nil] if {#real_pathname} cannot be read.
  def derived_real_path_sha1_hex_digest
    begin
      sha1 = Digest::SHA1.file(real_pathname.to_s)
    rescue Errno::ENOENT
      hex_digest = nil
    else
      hex_digest = sha1.hexdigest
    end

    hex_digest
  end

  # The type of the module. This would be called #type, but #type is reserved for ActiveRecord's single table
  # inheritance.
  #
  # @return [String] value in {Metasploit::Cache::Module::Ancestor::MODULE_TYPE_BY_DIRECTORY}.
  def module_type
    MODULE_TYPE_BY_DIRECTORY[module_type_directory]
  end

  # The directory under {Metasploit::Cache::Module::Path parent_path.real_path}.
  #
  # @return [String]
  def module_type_directory
    relative_file_names.first
  end

  # The real (absolute) path to the module file on-disk as a `Pathname`.
  #
  # @return [Pathname] unless {#parent_path} {Metasploit::Cache::Module::Path#real_path} or {#real_pathname} is `nil`.
  # @return [nil] otherwise
  def real_pathname
    if parent_path
      parent_real_pathname = parent_path.real_pathname

      if parent_real_pathname && relative_path
        parent_real_pathname.join(relative_path)
      end
    end
  end

  # The reference name of the module.  The name of the module under its {#module_type type}.
  #
  # @return [String] if {#real_pathname} is set and ends with {EXTENSION}.
  # @return [nil] otherwise.
  def reference_name
    derived = nil
    reference_name_file_names = relative_file_names.drop(1)
    reference_name_base_name = reference_name_file_names[-1]

    if reference_name_base_name
      if File.extname(reference_name_base_name) == EXTENSION
        reference_name_file_names[-1] = File.basename(reference_name_base_name, EXTENSION)
        derived = reference_name_file_names.join(REFERENCE_NAME_SEPARATOR)
      end
    end

    derived
  end

  # @!method real_path_modified_at=(real_path_modified_at)
  #   Sets {#real_path_modified_at}.
  #
  #   @param real_path_modified_at [String] The modification time of the module {#real_pathname file on-disk}.
  #   @return [void]

  # @!method real_path_sha1_hex_digest=(real_path_sha1_hex_digest)
  #   Sets {#real_path_sha1_hex_digest}.
  #
  #   @param real_path_sha1_hex_digest [String] The SHA1 hexadecimal digest of contents of the file at {#real_pathname}.
  #   @return [void]

  # @!method relationships=(relationships)
  #   Sets {#relationships}.
  #
  #   @param relationships [Enumerable<Metasploit::Cache::Model::Relationship>] Relates this
  #     {Metasploit::Cache::Module::Ancestor} to the
  #     {Metasploit::Cache::Module::Class Metasploit::Cache::Module::Classes} that
  #     {Metasploit::Cache::Module::Relationship#descendant descend} from the {Metasploit::Cache::Module::Ancestor}.
  #   @return [void]

  # File names on {#relative_pathname}.
  #
  # @return [Enumerator<String>]
  def relative_file_names
    relative_pathname = self.relative_pathname

    if relative_pathname
      relative_pathname.each_filename
    else
      # empty enumerator
      Enumerator.new { }
    end
  end

  # {#relative_path} as a `Pathname`.
  #
  # @return [Pathname] unless {#relative_path} is `nil`.
  # @return [nil] if {#relative_path} is `nil`.
  def relative_pathname
    if relative_path
      Pathname.new(relative_path)
    end
  end

  # @!method reference_name=(reference_name)
  #   Sets {#reference_name}.
  #
  #   @param reference_name [String] The name of the module under its {#module_type type}.
  #   @return [void]

  # The path relative to the {#module_type_directory} under the {Metasploit::Cache::Module::Path
  # parent_path.real_path}, including the file {EXTENSION extension}.
  #
  # @return [String] {#reference_name} + {EXTENSION}
  # @return [nil] if {#reference_name} is `nil`.
  def reference_path
    path = nil

    if reference_name
      path = "#{reference_name}#{EXTENSION}"
    end

    path
  end

  private

  # Whether this ancestor is being validated for loading.
  #
  # @return [true] if `#validation_context` is `:loading`
  # @return [false] otherwise
  def loading_context?
    validation_context == :loading
  end

  # Switch back to public for load hooks
  public

  Metasploit::Concern.run(self)
end
