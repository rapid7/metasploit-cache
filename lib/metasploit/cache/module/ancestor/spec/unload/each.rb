# @note This should only temporarily be used in `spec/spec_helper.rb` when
#   {Metasploit::Cache::Module::Ancestor::Spec::Unload::Suite.configure!` detects a leak.  Permanently having
#   {Metasploit::Cache::Module::Ancestor::Spec::Unload::Each.configure!} can lead to false positives when modules are
#   purposely loaded in a `before(:all)` and cleaned up in a `after(:all)`.
#
# Fails example if it leaks module loading constants.
module Metasploit::Cache::Module::Ancestor::Spec::Unload::Each
  #
  # CONSTANTS
  #

  LOG_PATHNAME = Pathname.new('log/metasploit/cache/module/ancestor/spec/unload/each.log')

  #
  # Module Methods
  #

  # Configures after(:each) callback for RSpec to fail example if leaked constants.
  #
  # @return [void]
  def self.configure!
    unless @configured
      RSpec.configure do |config|
        config.before(:each) do |example|
          # clean so that leaks from earlier example aren't attributed to this example
          leaks_cleaned = Metasploit::Cache::Module::Ancestor::Spec::Unload.unload

          if leaks_cleaned
            $stderr.puts "Cleaned leaked constants before #{example.metadata[:full_description]}"
          end

          Metasploit::Cache::Module::Ancestor::Spec::Unload::Each.leaks_cleaned ||= leaks_cleaned
        end

        config.after(:each) do |example|
          child_names = Metasploit::Cache::Module::Ancestor::Spec::Unload.to_enum(:each).to_a

          if child_names.length > 0
            lines = ['Leaked constants:']

            child_names.sort.each do |child_name|
              lines << "  #{child_name}"
            end

            lines << ''
            lines << "Add `include_context 'Metasploit::Cache::Module::Ancestor::Spec::Unload.unload'` to clean up constants from #{example.metadata[:full_description]}"

            message = lines.join("\n")

            # use caller metadata so that Jump to Source in the Rubymine RSpec running jumps to the example instead of
            # here
            fail RuntimeError, message
          end
        end

        config.after(:suite) do
          if Metasploit::Cache::Module::Ancestor::Spec::Unload::Each.leaks_cleaned?
            if LOG_PATHNAME.exist?
              LOG_PATHNAME.delete
            end
          else
            LOG_PATHNAME.open('w') { |f|
              f.puts(
                  "No leaks were cleaned by `Metasploit::Cache::Module::Ancestor::Spec::Unload::Each.configured!`. " \
                  "Remove it from `spec/spec_helper.rb` so it does not interfere with contexts that persist loaded " \
                  "modules for entire context and clean up modules in `after(:all)`"
              )
            }
          end
        end
      end

      @configured = true
    end
  end

  # Whether {configure!} was called
  #
  # @return [Boolean]
  def self.configured?
    !!@configured
  end

  # Adds action to `spec` task so that `rake spec` fails if {configured!} is unnecessary in `spec/spec_helper.rb` and
  # should be removed
  #
  # @return [void]
  def self.define_task
    Rake::Task.define_task('metasploit:cache:module:ancestor:spec:unload:each:clean') do
      if LOG_PATHNAME.exist?
        LOG_PATHNAME.delete
      end
    end

    Rake::Task.define_task(spec: 'metasploit:cache:module:ancestor:spec:unload:each:clean')

    Rake::Task.define_task(:spec) do
      if LOG_PATHNAME.exist?
        LOG_PATHNAME.open { |f|
          f.each_line do |line|
            $stderr.write line
          end
        }

        exit(1)
      end
    end
  end

  class << self
    attr_accessor :leaks_cleaned
  end

  # Is {Metasploit::Cache::Module::Ancestor::Spec::Unload::Each.configure!} still necessary or should it be removed?
  #
  # @return [true] if {configure!}'s `before(:each)` cleaned up leaked constants
  # @return [false] otherwise
  def self.leaks_cleaned?
    !!@leaks_cleaned
  end
end