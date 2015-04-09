source 'https://rubygems.org'

# Specify your gem's dependencies in metasploit-cache.gemspec
gemspec

# TODO remove once this version of metasploit-model is out of prerelease
gem 'metasploit-model',
    tag: 'v0.29.2.pre.validates.pre.nilness.pre.of',
    github: 'rapid7/metasploit-model'
# TODO remove once metasploit-version has owners besides Trevor and I can prerelease the gem.
gem 'metasploit-version',
    branch: 'v0.1.3.pre.changelog.pre.template',
    github: 'rapid7/metasploit-version',
    group: :development

group :content do
  gem 'metasploit-framework',
      github: 'rapid7/metasploit-framework',
      ref: '1099084fb04164034e5520564828d57915d3a63a'
  gem 'metasploit-framework-db',
      github: 'rapid7/metasploit-framework',
      ref: '1099084fb04164034e5520564828d57915d3a63a'

  #
  # These gem versions are taken from
  # https://github.com/rapid7/metasploit-framework/blob/1099084fb04164034e5520564828d57915d3a63a/Gemfile.lock and
  # need to be pinned so the schema.rb doesn't keep changing when `~>` compatible versions are released.
  #

  gem 'metasploit-credential', '0.14.0'
  gem 'metasploit_data_models', '0.23.0'
end

# used by dummy application
group :development, :test do
  # supplies factories for producing model instance for specs
  # Version 4.1.0 or newer is needed to support generate calls without the 'FactoryGirl.' in factory definitions syntax.
  gem 'factory_girl', '>= 4.1.0'
  # auto-load factories from spec/factories
  gem 'factory_girl_rails'
  # Use to create fake data
  gem 'faker'
  # tests compatibility with main progess bar target
  gem 'ruby-progressbar'
end

group :test do
  # rails is not used because activerecord should not be included, but rails would normally coordinate the versions
  # between its dependencies, which is now handled by this constraint.
  rails_version_constraint = [
      '>= 3.2.0',
      '< 4.0.0'
  ]

  # Dummy app uses actionpack for ActionController, but not rails since it doesn't use activerecord.
  gem 'actionpack', *rails_version_constraint
  # Test the shared examples and matchers
  gem 'aruba', github: 'rapid7/aruba', tag: 'v0.6.3.pre.metasploit.pre.yard.pre.port'
  # used for building markup for webpage factories
  gem 'builder'
  # simplecov test formatter and uploader for Coveralls.io
  gem 'coveralls', require: false
  # for cleaning the database before suite in case previous run was aborted without clean up
  gem 'database_cleaner'
  # RSpec formatter
  gem 'fivemat'
  # Engine tasks are loaded using railtie
  gem 'railties', *rails_version_constraint
  gem 'rspec'
  # need rspec-rails >= 2.12.0 as 2.12.0 adds support for redefining named subject in nested context that uses the
  # named subject from the outer context without causing a stack overflow.
  gem 'rspec-rails', '>= 2.12.0'
  # In a full rails project, factory_girl_rails would be in both the :development, and :test group, but since we only
  # want rails in :test, factory_girl_rails must also only be in :test.
  # add matchers from shoulda, such as validates_presence_of, which are useful for testing validations
  gem 'shoulda-matchers'
  # Coverage reports
  gem 'simplecov', require: false
  # defines time zones for activesupport.  Must be explicit since it is normally implicit with activerecord
  gem 'tzinfo'
end
