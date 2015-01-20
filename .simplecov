if ENV['TRAVIS'] == 'true'
  require 'coveralls'

  Coveralls.wear_merged!
else
  # RM_INFO is set when using Rubymine.  In Rubymine, starting SimpleCov is
  # controlled by running with coverage, so don't explicitly start coverage (and
  # therefore generate a report) when in Rubymine.  This _will_ generate a report
  # whenever `rake spec` is run.
  unless ENV['RM_INFO']
    SimpleCov.start
  end

  SimpleCov.configure do
    require 'pathname'

    root = Pathname.new(__FILE__).expand_path.parent

    # ignore this file
    add_filter root.join('.simplecov').to_path

    # Rake tasks aren't tested with rspec
    add_filter root.join('Rakefile').to_path
    add_filter root.join('lib/tasks').to_path

    #
    # Changed Files in Git Group
    # @see http://fredwu.me/post/35625566267/simplecov-test-coverage-for-changed-files-only
    #

    untracked = `git ls-files --exclude-standard --others`
    unstaged = `git diff --name-only`
    staged = `git diff --name-only --cached`
    all = untracked + unstaged + staged
    changed_filenames = all.split("\n")

    add_group 'Changed' do |source_file|
      changed_filenames.detect { |changed_filename|
        source_file.filename.end_with?(changed_filename)
      }
    end

    add_group 'Models', root.join('app/models').to_path
    add_group 'Validators', root.join('app/validators').to_path
    add_group 'Libraries', root.join('lib').to_path

    #
    # Specs are reported on to ensure that all examples are being run and all
    # lets, befores, afters, etc are being used.
    #

    spec = root.join('spec')
    factories_path = spec.join('factories').to_path
    add_group 'Factories', factories_path

    spec_support = spec.join('support')
    shared = spec_support.join('shared')

    contexts_path = shared.join('context').to_path
    add_group 'Shared Contexts', contexts_path

    examples_path = shared.join('examples').to_path
    add_group 'Shared Examples', examples_path

    dummy_path = spec.join('dummy').to_path
    add_group 'Dummy Application', dummy_path

    spec_path = spec.to_path
    spec_support_path = spec_support.to_path
    add_group('Specs') { |source_file|
      source_path = source_file.filename

      [dummy_path, factories_path, spec_support_path].none? { |path|
        source_path.start_with? path
      } && source_path.start_with?(spec_path)
    }

    # NOTE: configure `minimum_coverage` in `Rakefile` for the `coverage` task
  end
end
