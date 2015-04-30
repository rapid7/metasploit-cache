# @note This should only temporarily be used in `spec/spec_helper.rb` when
#   {Metasploit::Cache::Spec::Unload::Suite.configure!} detects a leak.  Permanently having
#   {Metasploit::Cache::Spec::Unload::Each.configure!} can lead to false positives when modules are purposely loaded in
#   a `before(:all)` and cleaned up in a `after(:all)`.
#
# Fails example if it leaks module loading constants.
module Metasploit::Cache::Spec::Unload::Each
  #
  # CONSTANTS
  #

  LOG_PATHNAME = Pathname.new('log/metasploit/cache/spec/unload/each.log')

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
          leaks_cleaned = Metasploit::Cache::Spec::Unload.unload

          if leaks_cleaned
            $stderr.puts "Cleaned leaked constants before #{example.metadata[:full_description]}"
          end

          Metasploit::Cache::Spec::Unload::Each.leaks_cleaned ||= leaks_cleaned
        end

        config.after(:each) do |example|
          lines = []

          Metasploit::Cache::Spec::Unload.each do |parent_constant, child_name|
            lines << "  #{parent_constant}::#{child_name}"
          end

          if lines.length > 0
            lines.sort!

            lines.unshift 'Leaked constants:'

            lines << ''
            lines << "Add `include_context 'Metasploit::Cache::Spec::Unload.unload'` to clean up constants from #{example.metadata[:full_description]}"

            message = lines.join("\n")

            # use caller metadata so that Jump to Source in the Rubymine RSpec running jumps to the example instead of
            # here
            fail RuntimeError, message
          end
        end

        config.after(:suite) do
          if Metasploit::Cache::Spec::Unload::Each.leaks_cleaned?
            if LOG_PATHNAME.exist?
              LOG_PATHNAME.delete
            end
          else
            LOG_PATHNAME.open('w') { |f|
              f.puts(
                  "No leaks were cleaned by `Metasploit::Cache::Spec::Unload::Each.configure!`. " \
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

  # Adds action to `spec` task so that `rake spec` fails if {configure!} is unnecessary in `spec/spec_helper.rb` and
  # should be removed
  #
  # @return [void]
  def self.define_task
    Rake::Task.define_task('metasploit:cache:spec:unload:each:clean') do
      if LOG_PATHNAME.exist?
        LOG_PATHNAME.delete
      end
    end

    Rake::Task.define_task(spec: 'metasploit:cache:spec:unload:each:clean')

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

  # Is {Metasploit::Cache::Spec::Unload::Each.configure!} still necessary or should it be removed?
  #
  # @return [true] if {configure!}'s `before(:each)` cleaned up leaked constants
  # @return [false] otherwise
  def self.leaks_cleaned?
    !!@leaks_cleaned
  end
end