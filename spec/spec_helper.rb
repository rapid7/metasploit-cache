# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'
require 'bundler'
Bundler.setup(:default, :test)

# require before anything else so coverage is shown for all project files
require 'simplecov'

require File.expand_path('../dummy/config/environment.rb',  __FILE__)
require 'rspec/rails'

#
# Gems
#

require 'metasploit/version'

roots = []

# Use find_all_by_name instead of find_by_name as find_all_by_name will return pre-release versions
metasploit_version_gem_specification = Gem::Specification.find_all_by_name('metasploit-version').first
roots << metasploit_version_gem_specification.gem_dir

roots << Metasploit::Model::Engine.root
roots << Metasploit::Cache::Engine.root

roots.each do |root|
  Dir[File.join(root, 'spec', 'support', '**', '*.rb')].each do |f|
    require f
  end
end

RSpec.configure do |config|
  config.raise_errors_for_deprecations!

  config.expose_dsl_globally = false

  # These two settings work together to allow you to limit a spec run
  # to individual examples or groups you care about by tagging them with
  # `:focus` metadata. When nothing is tagged with `:focus`, all examples
  # get run.
  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  # allow more verbose output when running an individual spec file.
  if config.files_to_run.one?
    # RSpec filters the backtrace by default so as not to be so noisy.
    # This causes the full backtrace to be printed when running a single
    # spec file (e.g. to troubleshoot a particular spec failure).
    config.full_backtrace = true
  end

  # Print the 10 slowest examples and example groups at the
  # end of the spec run, to help surface which specs are running
  # particularly slow.
  config.profile_examples = 10

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand config.seed

  config.expect_with :rspec do |expectations|
    # Enable only the newer, non-monkey-patching expect syntax.
    expectations.syntax = :expect
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Enable only the newer, non-monkey-patching expect syntax.
    # For more details, see:
    #   - http://teaisaweso.me/blog/2013/05/27/rspecs-new-message-expectation-syntax/
    mocks.syntax = :expect

    mocks.patch_marshal_to_support_partial_doubles = false

    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object.
    mocks.verify_partial_doubles = true
  end

  config.before(:suite) do
    # this must be explicitly set here because it should always be spec/tmp for w/e project is using
    # Metasploit::Model::Spec to handle file system clean up.
    Metasploit::Model::Spec.temporary_pathname = Metasploit::Cache::Engine.root.join('spec', 'tmp')
    # Clean up any left over files from a previously aborted suite
    Metasploit::Model::Spec.remove_temporary_pathname

    # catch missing translations
    I18n.exception_handler = Metasploit::Model::Spec::I18nExceptionHandler.new
  end

  config.after(:each) do
    Metasploit::Model::Spec.remove_temporary_pathname
  end
end
