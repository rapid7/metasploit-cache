if RUBY_ENGINE == 'ruby'
  # Has to be the first file required so that all other files show coverage information
  require 'simplecov'
end

#
# Standard Library
#

require 'pathname'

#
# Gems
#

require 'aruba/cucumber'
# only does jruby customization if actually in JRuby
require 'aruba/jruby'

if defined? SimpleCov
  Before do |scenario|
    command_name = case scenario
                   when Cucumber::RunningTestCase::Scenario
                     "#{scenario.feature.title} #{scenario.name}"
                   else
                     raise TypeError, "Don't know how to extract command name from #{scenario.class}"
                   end

    # Used in simplecov_setup so that each scenario has a different name and their coverage results are merged instead
    # of overwriting each other as 'Cucumber Features'
    set_env('SIMPLECOV_COMMAND_NAME', command_name)

    simplecov_setup_pathname = Pathname.new(__FILE__).expand_path.parent.join('simplecov_setup')
    # set environment variable so child processes will merge their coverage data with parent process's coverage data.
    set_env('RUBYOPT', "-r#{simplecov_setup_pathname} #{ENV['RUBYOPT']}")
  end
end

Before do
  @aruba_timeout_seconds = 12
end