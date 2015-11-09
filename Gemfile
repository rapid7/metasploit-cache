source 'https://rubygems.org'

# Specify your gem's dependencies in metasploit-cache.gemspec
gemspec

group :content do
  gem 'metasploit-framework',
      github: 'rapid7/metasploit-framework',
      ref: '1bfa84b37bcacb7e634a430da42053f67a942627'
  gem 'metasploit-framework-db',
      github: 'rapid7/metasploit-framework',
      ref: '1bfa84b37bcacb7e634a430da42053f67a942627'

  #
  # These gem versions are taken from
  # https://github.com/rapid7/metasploit-framework/blob/1099084fb04164034e5520564828d57915d3a63a/Gemfile.lock and
  # need to be pinned so the schema.rb doesn't keep changing when `~>` compatible versions are released.
  #

  gem 'metasploit-credential', '1.0.0'
  gem 'metasploit_data_models', '1.2.5'
end

# used by dummy application
group :development, :test do
  # Templates for Metasploit Modules
  gem 'cells', '~> 4.0'
  # Template engine must be explicitly selected for cells
  gem 'cells-erb'
  # Twins for cells so that options can be passed to cell() calls
  gem 'disposable', '~> 0.0.9'
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
      '>= 4.0.9',
      '< 4.1.0'
  ]

  # Dummy app uses actionpack for ActionController, but not rails since it doesn't use activerecord.
  gem 'actionpack', *rails_version_constraint
  # Test the shared examples and matchers
  gem 'aruba', github: 'rapid7/aruba', tag: 'v0.6.3.pre.metasploit.pre.yard.pre.port'
  # used for building markup for webpage factories
  gem 'builder'
  # run child processes in tests
  gem 'childprocess'
  # simplecov test formatter and uploader for Coveralls.io
  gem 'coveralls', require: false
  # Test shared examples and matchers.  Used with aruba
  # TODO get fivemat working with cucumber 2.0.1
  gem 'cucumber', '2.0.0'
  # for cleaning the database before suite in case previous run was aborted without clean up
  gem 'database_cleaner'
  # RSpec formatter
  gem 'fivemat'
  # Engine tasks are loaded using railtie
  gem 'railties', *rails_version_constraint
  gem 'rspec'
  # Test cells used to generate templates for Metasploit Modules
  gem 'rspec-cells', '~> 0.3.3'
  # need rspec-rails >= 2.12.0 as 2.12.0 adds support for redefining named subject in nested context that uses the
  # named subject from the outer context without causing a stack overflow.
  gem 'rspec-rails', '>= 2.12.0'
  # In a full rails project, factory_girl_rails would be in both the :development, and :test group, but since we only
  # want rails in :test, factory_girl_rails must also only be in :test.
  # add matchers from shoulda, such as validates_presence_of, which are useful for testing validations
  gem 'shoulda-matchers', '~> 3.0'
  # Coverage reports
  gem 'simplecov', require: false
  # defines time zones for activesupport.  Must be explicit since it is normally implicit with activerecord
  gem 'tzinfo'
end

group :postgresql do
  gem 'pg'
end

group :sqlite3 do
  gem 'sqlite3'
end
