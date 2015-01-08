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

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

# Use find_all_by_name instead of find_by_name as find_all_by_name will return pre-release versions
gem_specification = Gem::Specification.find_all_by_name('metasploit-yard').first

Dir[File.join(gem_specification.gem_dir, 'lib', 'tasks', '**', '*.rake')].each do |rake|
  load rake
end

#
# Eager load before yard docs so that ActiveRecord::Base subclasses are loaded for yard-metasploit-erd
#

task 'yard:doc' => :eager_load

task eager_load: :environment do
  Rails.application.eager_load!
end
