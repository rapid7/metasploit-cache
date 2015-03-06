# Adds {#each_changed} method to {Metasploit::Cache::Module::Path} associations, so that
# {Metasploit::Cache::Module::Ancestor} from the given association can be populated from the file system.
module Metasploit::Cache::Module::Path::AssociationExtension
  # @note The yielded {Metasploit::Cache::Module::Ancestor} may contain unsaved changes.  It is the responsibility
  #   of the caller to save the record.
  #
  # @overload each_changed(changed: false, progress_bar: Metasploit::Cache::NullProgressBar.new, &block)
  #   Yields each module ancestor that is changed under this association's `relative_path_prefix`, as defined by
  #   {Metasploit::Cache::Module::Ancestor.restrict} and {Metasploit::Cache::Payload::Ancestor.restrict}.
  #
  #   @yield [module_ancestor]
  #   @yieldparam module_ancestor [Metasploit::Cache::Module::Ancestor] a changed, or in the case `changed` is
  #     `true`, assumed changed, {Metasploit::Cache::Module::Ancestor}.
  #   @yieldreturn [void]
  #   @return [void]
  #
  # @overload each_changed(changed: false, progress_bar: Metasploit::Cache::NullProgressBar.new)
  #   Returns enumerator that yields each module ancestor that is changed under {#real_path}.
  #
  #   @return [Enumerator<Metasploit::Cache::Module::Ancestor>]
  #
  # @param assume_changed [Boolean] if `true`, assume the {Metasploit::Cache::Module::Ancestor#real_path_modified_at}
  #   and {Metasploit::Cache::Module::Ancestor#real_path_sha1_hex_digest} have changed and that
  #   {Metasploit::Cache::Module::Ancestor} should be yielded.
  # @param progress_bar [ProgressBar, #total=, #increment] a ruby `ProgressBar` or similar object that supports the
  #   `#total=` and `#increment` API for monitoring the progress of the enumerator.  `#total` will be set to total
  #   number of {#relative_paths} under this module path, not just the number of changed (updated or new) real paths.
  #   `#increment` will be called whenever a relative path is visited, which means it can be called when there is no
  #   yielded module ancestor because that module ancestor was unchanged. When {#each_changed} returns, `#increment`
  #   will have been called the same number of times as the value passed to `#total=` and `#finished?` will be `true`.
  def each_changed(assume_changed: false, progress_bar: Metasploit::Cache::NullProgressBar.new, &block)
    Metasploit::Cache::Module::Ancestor.each_changed(
        assume_changed: assume_changed,
        progress_bar: progress_bar,
        relative_paths: relative_paths,
        scope: self,
        &block
    )
  end

  private

  # File::Find rule for find all {Metasploit::Cache::Module::Ancestor#relative_path} that map to the class for the
  # extended association under {Metasploit::Cache::Module::Path#real_path} on-disk.
  #
  # @return [File::Find]
  def real_path_rule
    File::Find.new(
        ftype: 'file',
        path: proxy_association.owner.real_pathname.join(
            proxy_association.reflection.klass.relative_path_prefix
        ).to_path,
        pattern: "*#{Metasploit::Cache::Module::Ancestor::EXTENSION}"
    )
  end

  # {Metasploit::Cache::Module::Ancestor#relative_path} that map to the class for the extended association under
  # {Metasploit::Cache::Module::Path#real_path} on-disk.
  #
  # @return [Array<String>]
  def relative_paths
    module_path_real_pathname = proxy_association.owner.real_pathname

    real_path_rule.find.map { |real_path|
      real_pathname = Pathname.new(real_path)
      relative_pathname = real_pathname.relative_path_from(module_path_real_pathname)

      relative_pathname.to_path
    }
  end
end