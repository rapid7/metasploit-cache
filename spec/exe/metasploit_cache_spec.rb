RSpec.describe 'metasploit-cache', :content do
  def db_content_load
    db_content_purge
    db_content_load_schema

    expect(Metasploit::Cache::Module::Class::Name.count).to eq(0)
  end

  def db_content_load_schema
    begin
      ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations.fetch('content'))
      ActiveRecord::Schema.verbose = false
      db_schema_load
    ensure
      ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations.fetch('test'))
    end
  end

  def db_content_purge
    ActiveRecord::Tasks::DatabaseTasks.root = Metasploit::Cache::Engine.root

    ActiveRecord::Tasks::DatabaseTasks.purge ActiveRecord::Base.configurations.fetch('content')
  end

  def db_schema_load
    file = File.join('spec', 'dummy', 'db', 'schema.rb')

    if File.exist?(file)
      load(file)
    else
      abort %{#{file} doesn't exist yet. Run `rake db:migrate` to create it, then try again. If you do not intend to use a database, you should instead alter #{Rails.root}/config/application.rb to limit the frameworks that will be loaded.}
    end
  end

  #
  # Callbacks
  #
  
  before(:all) do
    db_content_load
    
    metasploit_framework_root = Metasploit::Framework::Engine.root
    
    require 'childprocess'

    metasploit_cache_load = ChildProcess.build(
        'bundle',
        'exec',
        'metasploit-cache',
        'load',
        metasploit_framework_root.join('modules').to_path,
        '--database-yaml', 'config/database.yml',
        '--environment', 'content',
        '--include', metasploit_framework_root.to_path,
                     metasploit_framework_root.join('app', 'validators').to_path,
        '--require', 'metasploit/framework',
                     'metasploit/framework/executable_path_validator',
                     'metasploit/framework/file_path_validator',
        '--gem', 'metasploit-framewor',
        '--logger-severity', 'ERROR',
        '--name', 'modules'
    )

    @metasploit_cache_load_out = Tempfile.new(['metasploit-cache-load', '.log'])
    @metasploit_cache_load_out.sync = true

    metasploit_cache_load.cwd = Metasploit::Cache::Engine.root.join('spec', 'dummy').to_path
    metasploit_cache_load.io.stdout = @metasploit_cache_load_out

    require 'benchmark'

    Benchmark.bm do |report|
      report.report do
        metasploit_cache_load.start
        metasploit_cache_load.poll_for_exit(10.minutes)
      end
    end

    expect(metasploit_cache_load.exit_code).to eq(0),
                                               ->(){
                                                 @metasploit_cache_load_out.rewind
                                                 @metasploit_cache_load_out.read
                                               }
  end

  after(:all) {
    @metasploit_cache_load_out.rewind
    puts @metasploit_cache_load_out.read

    # close and delete
    @metasploit_cache_load_out.close!
  }

  # :nocov:
  # Can't just use the tag on the context because the below code will still run even if tag is filtered out
  unless Bundler.settings.without.include? 'content'
    context 'metasploit-framework', :content do
      module_path_real_paths = Metasploit::Framework::Engine.paths['modules'].existent_directories

      module_path_real_paths.each do |module_path_real_path|
        module_path_real_pathname = Pathname.new(module_path_real_path)
        module_path_relative_pathname = module_path_real_pathname.relative_path_from(
            Metasploit::Framework::Engine.root
        )

        # use relative pathname so that context name is not dependent on build directory
        context module_path_relative_pathname.to_s do
          #
          # Context Methods
          #

          # Yields each relative Pathname under `relative_path_prefix` under `module_path_real_pathname` that points to
          # {Metasploit::Cache::Module::Ancestor#real_pathname}.
          #
          # @param max_run_count [Integer, nil] The max number of examples to run from the context.
          # @param module_path_real_pathname [Pathname] {Metasploit::Cache::Module::Path#real_pathname}
          # @param module_type [Stirng] module type for reference name.
          # @param pending_by_reference_name [Hash{String => String}] Maps reference name to pending reason.
          # @param relative_path_prefix [String] Path prefix under `module_path_real_pathname` to search for ancestor
          #   paths.
          # @yield [relative_pathname]
          # @yieldparam relative_pathname [Pathname] pathname relative to `module_path_real_pathname`.
          # @yieldreturn [String] reference name derived from relative_pathname
          # @return [void]
          def self.each_reference_name(max_run_count: nil, module_path_real_pathname:, module_type:, pending_reason_by_reference_name: {}, relative_path_prefix:)
            rule = Metasploit::Cache::Module::Path::AssociationExtension.real_path_rule(
                module_path_real_pathname: module_path_real_pathname,
                relative_path_prefix: relative_path_prefix
            )

            run_count = 0

            rule.find do |real_path|
              real_pathname = Pathname.new(real_path)
              relative_pathname = real_pathname.relative_path_from(module_path_real_pathname)

              reference_name = yield relative_pathname


              context_options = {}
              pending_reason = pending_reason_by_reference_name[reference_name]

              if pending_reason
                context_options[:pending] = pending_reason
              end

              context reference_name, context_options do
                unless pending_reason
                  if max_run_count
                    before(:each) do
                      run_count += 1

                      if run_count > max_run_count
                        skip "Skipping because #{max_run_count} Metasploit Modules with ancestors under " \
                           "#{relative_path_prefix} have been tested already and testing them all takes too long"
                      end
                    end
                  end
                end

                it "can be `use`d" do
                  metasploit_framework_root = Metasploit::Framework::Engine.root

                  metasploit_cache_use = ChildProcess.build(
                      'bundle',
                      'exec',
                      'metasploit-cache',
                      'use',
                      "#{module_type}/#{reference_name}",
                      '--database-yaml', 'config/database.yml',
                      '--environment', 'content',
                      '--include', metasploit_framework_root.to_path,
                      metasploit_framework_root.join('app', 'validators').to_path,
                      '--require', 'metasploit/framework',
                      'metasploit/framework/executable_path_validator',
                      'metasploit/framework/file_path_validator',
                      '--logger-severity', 'ERROR'
                  )

                  metasploit_cache_use_out = Tempfile.new(['metasploit-cache-use', '.log'])
                  metasploit_cache_use_out.sync = true

                  metasploit_cache_use.cwd = Metasploit::Cache::Engine.root.join('spec', 'dummy').to_path
                  metasploit_cache_use.io.stdout = metasploit_cache_use_out
                  metasploit_cache_use.start
                  metasploit_cache_use.wait

                  expect(metasploit_cache_use.exit_code).to eq(0), ->(){
                    metasploit_cache_use_out.rewind

                    "metasploit-cache use #{full_name} exited with non-zero status " \
                      "(#{metasploit_cache_use.exit_code}):\n#{metasploit_cache_use_out.read}"
                  }
                end
              end
            end
          end

          #
          # Shared Examples
          #

          shared_examples_for 'can use full names' do |module_type, max_run_count: nil|
            context module_type do
              type_directory = Metasploit::Cache::Module::Ancestor::DIRECTORY_BY_MODULE_TYPE.fetch(module_type)

              each_reference_name(
                  max_run_count: max_run_count,
                  module_path_real_pathname: module_path_real_pathname,
                  module_type: module_type,
                  relative_path_prefix: type_directory
              ) { |relative_pathname|
                Metasploit::Cache::Module::Class::Namable.reference_name(
                    relative_file_names: relative_pathname.each_filename,
                    scoping_levels: 1
                )
              }
            end
          end

          include_examples 'can use full names',
                           'auxiliary',
                           max_run_count: 5

          include_examples 'can use full names',
                           'encoder',
                           max_run_count: 5

          include_examples 'can use full names',
                           'exploit',
                           max_run_count: 5

          include_examples 'can use full names', 'nop'

          context 'payload' do
            context '(single)' do
              each_reference_name(
                  max_run_count: 5,
                  module_path_real_pathname: module_path_real_pathname,
                  module_type: 'payload',
                  pending_reason_by_reference_name: {
                      'bsd/x64/shell_bind_tcp' => 'NameError uninitialized constant Msf::Sessions::CommandShellUnix',
                      'bsd/x64/shell_reverse_tcp' => 'NameError uninitialized constant Msf::Sessions::CommandShellUnix',
                      'generic/shell_bind_tcp' => 'NameError uninitialized constant Msf::Sessions::CommandShell',
                      'generic/shell_reverse_tcp' => 'NameError uninitialized constant Msf::Sessions::CommandShell',
                      'osx/x64/shell_bind_tcp' => 'NameError uninitialized constant Msf::Sessions::CommandShellUnix',
                      'osx/x64/shell_reverse_tcp' => 'NameError uninitialized constant Msf::Sessions::CommandShellUnix'
                  },
                  relative_path_prefix: 'payloads/singles'
              ) { |relative_pathname|
                Metasploit::Cache::Module::Class::Namable.reference_name(
                    relative_file_names: relative_pathname.each_filename,
                    scoping_levels: 2
                )
              }
            end
          end

          include_examples 'can use full names',
                           'post',
                           max_run_count: 5
        end
      end
    end
  end
end