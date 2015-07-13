require 'bundler/gem_tasks'
require 'bundler/setup'

APP_RAKEFILE = File.expand_path('../spec/dummy/Rakefile', __FILE__)
load 'rails/tasks/engine.rake'

Bundler::GemHelper.install_tasks

#
# load rake files like a normal rails app
# @see http://viget.com/extend/rails-engine-testing-with-rspec-capybara-and-factorygirl
#

pathname = Pathname.new(__FILE__)
root = pathname.parent
rakefile_glob = root.join('lib', 'tasks', '**', '*.rake').to_path

Dir.glob(rakefile_glob) do |rakefile|
  load rakefile
end

require 'cucumber'
require 'cucumber/rake/task'
require 'rspec/core/rake_task'

Cucumber::Rake::Task.new do |t|
  t.cucumber_opts = 'features --format Fivemat'
end

# Depend on app:db:test:prepare so that test database is recreated just like in a full rails app
# @see http://viget.com/extend/rails-engine-testing-with-rspec-capybara-and-factorygirl
RSpec::Core::RakeTask.new(spec: 'app:db:test:prepare')


require 'coveralls/rake/task'
Coveralls::RakeTask.new

task :coverage do
  # disable SimpleCov.start in `.simplecov`
  ENV['SIMPLECOV_MERGE'] = 'true'
  require 'simplecov'

  SimpleCov.configure do
    minimum_coverage 100
    refuse_coverage_drop
  end

  merged_results = SimpleCov::ResultMerger.merged_result

  default_external_encoding_before = Encoding.default_external
  default_internal_encoding_before = Encoding.default_internal

  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8

  begin
    if ENV['TRAVIS'] == 'true'
      Rake.application['coveralls:push'].invoke
    else
      require 'simplecov-html'

      SimpleCov::Formatter::HTMLFormatter.new.format merged_results
    end
  ensure
    Encoding.default_external = default_external_encoding_before
    Encoding.default_internal = default_internal_encoding_before
  end

  #
  # 'simplecov/defaults' at_exit only works on unmerged results, so adapt it here to work on merged results.
  #
  # @see https://github.com/colszowka/simplecov/blob/47b9a891dfb36d0271b729fa18620429455fda75/lib/simplecov/defaults.rb#L42-L83
  #

  covered_percent = merged_results.covered_percent.round(2)
  exit_status = SimpleCov::ExitCodes::SUCCESS

  if covered_percent < SimpleCov.minimum_coverage
    $stderr.puts "Coverage (%.2f%%) is below the expected minimum coverage (%.2f%%)." % \
                     [covered_percent, SimpleCov.minimum_coverage]

    exit_status = SimpleCov::ExitCodes::MINIMUM_COVERAGE
  elsif (last_run = SimpleCov::LastRun.read)
    diff = last_run['result']['covered_percent'] - covered_percent

    if diff > SimpleCov.maximum_coverage_drop
      $stderr.puts "Coverage has dropped by %.2f%% since the last time (maximum allowed: %.2f%%)." % \
                       [diff, SimpleCov.maximum_coverage_drop]

      exit_status = SimpleCov::ExitCodes::MAXIMUM_COVERAGE_DROP
    end
  end

  SimpleCov::LastRun.write(:result => {:covered_percent => covered_percent})

  if exit_status != SimpleCov::ExitCodes::SUCCESS
    Kernel.exit exit_status
  end
end

task default: :coverage

namespace :app do
  namespace :db do
    # Add onto the task so that it can undo engine paths added by metasploit-framework and its dependencies
    task :load_config do
      ActiveRecord::Migrator.migrations_paths = Metasploit::Cache::Engine.instance.paths['db/migrate'].to_a
    end
  end
end

# Use find_all_by_name instead of find_by_name as find_all_by_name will return pre-release versions
gem_specification = Gem::Specification.find_all_by_name('metasploit-yard').first

Dir[File.join(gem_specification.gem_dir, 'lib', 'tasks', '**', '*.rake')].each do |rake|
  load rake
end

#
# Eager load before yard docs so that ActiveRecord::Base subclasses are loaded for yard-metasploit-erd
#

task 'yard:doc' => :eager_load
task 'yard:doc' => :patch_rails_erd70

task eager_load: :environment do
  Rails.application.eager_load!
end

task patch_rails_erd70: :environment do
  # Patch from https://github.com/voormedia/rails-erd/issues/70#issuecomment-63645855 to work around
  # Metasploit::Cache::Exploit::Instance#default_exploit_target -> Metasploit::Cache::Exploit::Target#exploit_instance
  # and
  # Metasploit::Cache::Exploit::Instance#exploit_targets -> Metasploit::Cache:Exploit::Target#exploit_instance causing
  # `in routesplines, cannot find NORMAL edge`

  require 'rails_erd'
  require 'rails_erd/domain/relationship'

  module RailsERD
    class Domain
      class Relationship
        class << self
          private

          def association_identity(association)
            Set[association_owner(association), association_target(association)]
          end
        end
      end
    end
  end
end

Metasploit::Cache::Spec::Unload.define_task
