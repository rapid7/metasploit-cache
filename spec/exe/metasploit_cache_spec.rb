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
        '--gem', 'metasploit-framework',
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

          def self.reference_name_context(module_type, reference_name, pending_reason_by_reference_name: {}, run_counter:)
            context_options = {}
            pending_reason = pending_reason_by_reference_name[reference_name]

            if pending_reason
              context_options[:pending] = pending_reason
            end

            context reference_name, context_options do
              unless pending_reason
                if run_counter.max
                  before(:each) do
                    run_counter.count += 1

                    if run_counter.count > run_counter.max
                      skip "Skipping because #{run_counter.max} Metasploit Modules have been tested already and testing them all takes too long"
                    end
                  end
                end
              end

              full_name = "#{module_type}/#{reference_name}"

              it "can be `use`d" do
                metasploit_framework_root = Metasploit::Framework::Engine.root

                metasploit_cache_use = ChildProcess.build(
                    'bundle',
                    'exec',
                    'metasploit-cache',
                    'use',
                    full_name,
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

            run_counter = Metasploit::Cache::Spec::RunCounter.new max: max_run_count

            rule.find do |real_path|
              real_pathname = Pathname.new(real_path)
              relative_pathname = real_pathname.relative_path_from(module_path_real_pathname)

              reference_name = yield relative_pathname

              reference_name_context module_type,
                                     reference_name,
                                     pending_reason_by_reference_name: pending_reason_by_reference_name,
                                     run_counter: run_counter
            end
          end

          #
          # Shared Examples
          #

          shared_examples_for 'can use full names' do |module_type, max_run_count: nil, pending_reason_by_reference_name: {}|
            context module_type do
              type_directory = Metasploit::Cache::Module::Ancestor::DIRECTORY_BY_MODULE_TYPE.fetch(module_type)

              each_reference_name(
                  max_run_count: max_run_count,
                  module_path_real_pathname: module_path_real_pathname,
                  module_type: module_type,
                  pending_reason_by_reference_name: pending_reason_by_reference_name,
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

            context '(staged)' do
              payload_staged_reference_names = %w{
                  android/meterpreter/reverse_http
                  android/meterpreter/reverse_https
                  android/meterpreter/reverse_tcp
                  android/shell/reverse_http
                  android/shell/reverse_https
                  android/shell/reverse_tcp
                  java/meterpreter/bind_tcp
                  java/meterpreter/reverse_http
                  java/meterpreter/reverse_https
                  java/meterpreter/reverse_tcp
                  java/shell/bind_tcp
                  java/shell/reverse_http
                  java/shell/reverse_https
                  java/shell/reverse_tcp
                  netware/shell/reverse_tcp
                  php/meterpreter/bind_tcp
                  php/meterpreter/bind_tcp_ipv6
                  php/meterpreter/bind_tcp_ipv6_uuid
                  php/meterpreter/bind_tcp_uuid
                  php/meterpreter/reverse_tcp
                  php/meterpreter/reverse_tcp_uuid
                  python/meterpreter/bind_tcp
                  python/meterpreter/bind_tcp_uuid
                  python/meterpreter/reverse_http
                  python/meterpreter/reverse_https
                  python/meterpreter/reverse_tcp
                  python/meterpreter/reverse_tcp_uuid
                  windows/dllinject/bind_hidden_ipknock_tcp
                  windows/dllinject/bind_hidden_tcp
                  windows/dllinject/bind_ipv6_tcp
                  windows/dllinject/bind_ipv6_tcp_uuid
                  windows/dllinject/bind_nonx_tcp
                  windows/dllinject/bind_tcp
                  windows/dllinject/bind_tcp_rc4
                  windows/dllinject/bind_tcp_uuid
                  windows/dllinject/find_tag
                  windows/dllinject/reverse_hop_http
                  windows/dllinject/reverse_http
                  windows/dllinject/reverse_http_proxy_pstore
                  windows/dllinject/reverse_https
                  windows/dllinject/reverse_https_proxy
                  windows/dllinject/reverse_ipv6_tcp
                  windows/dllinject/reverse_nonx_tcp
                  windows/dllinject/reverse_ord_tcp
                  windows/dllinject/reverse_tcp
                  windows/dllinject/reverse_tcp_allports
                  windows/dllinject/reverse_tcp_dns
                  windows/dllinject/reverse_tcp_rc4
                  windows/dllinject/reverse_tcp_rc4_dns
                  windows/dllinject/reverse_tcp_uuid
                  windows/dllinject/reverse_winhttp
                  windows/dllinject/reverse_winhttps
                  windows/meterpreter/bind_hidden_ipknock_tcp
                  windows/meterpreter/bind_hidden_tcp
                  windows/meterpreter/bind_ipv6_tcp
                  windows/meterpreter/bind_ipv6_tcp_uuid
                  windows/meterpreter/bind_nonx_tcp
                  windows/meterpreter/bind_tcp
                  windows/meterpreter/bind_tcp_rc4
                  windows/meterpreter/bind_tcp_uuid
                  windows/meterpreter/find_tag
                  windows/meterpreter/reverse_hop_http
                  windows/meterpreter/reverse_http
                  windows/meterpreter/reverse_http_proxy_pstore
                  windows/meterpreter/reverse_https
                  windows/meterpreter/reverse_https_proxy
                  windows/meterpreter/reverse_ipv6_tcp
                  windows/meterpreter/reverse_nonx_tcp
                  windows/meterpreter/reverse_ord_tcp
                  windows/meterpreter/reverse_tcp
                  windows/meterpreter/reverse_tcp_allports
                  windows/meterpreter/reverse_tcp_dns
                  windows/meterpreter/reverse_tcp_rc4
                  windows/meterpreter/reverse_tcp_rc4_dns
                  windows/meterpreter/reverse_tcp_uuid
                  windows/meterpreter/reverse_winhttp
                  windows/meterpreter/reverse_winhttps
                  windows/patchupdllinject/bind_hidden_ipknock_tcp
                  windows/patchupdllinject/bind_hidden_tcp
                  windows/patchupdllinject/bind_ipv6_tcp
                  windows/patchupdllinject/bind_ipv6_tcp_uuid
                  windows/patchupdllinject/bind_nonx_tcp
                  windows/patchupdllinject/bind_tcp
                  windows/patchupdllinject/bind_tcp_rc4
                  windows/patchupdllinject/bind_tcp_uuid
                  windows/patchupdllinject/find_tag
                  windows/patchupdllinject/reverse_hop_http
                  windows/patchupdllinject/reverse_http
                  windows/patchupdllinject/reverse_http_proxy_pstore
                  windows/patchupdllinject/reverse_https
                  windows/patchupdllinject/reverse_https_proxy
                  windows/patchupdllinject/reverse_ipv6_tcp
                  windows/patchupdllinject/reverse_nonx_tcp
                  windows/patchupdllinject/reverse_ord_tcp
                  windows/patchupdllinject/reverse_tcp
                  windows/patchupdllinject/reverse_tcp_allports
                  windows/patchupdllinject/reverse_tcp_dns
                  windows/patchupdllinject/reverse_tcp_rc4
                  windows/patchupdllinject/reverse_tcp_rc4_dns
                  windows/patchupdllinject/reverse_tcp_uuid
                  windows/patchupdllinject/reverse_winhttp
                  windows/patchupdllinject/reverse_winhttps
                  windows/patchupmeterpreter/bind_hidden_ipknock_tcp
                  windows/patchupmeterpreter/bind_hidden_tcp
                  windows/patchupmeterpreter/bind_ipv6_tcp
                  windows/patchupmeterpreter/bind_ipv6_tcp_uuid
                  windows/patchupmeterpreter/bind_nonx_tcp
                  windows/patchupmeterpreter/bind_tcp
                  windows/patchupmeterpreter/bind_tcp_rc4
                  windows/patchupmeterpreter/bind_tcp_uuid
                  windows/patchupmeterpreter/find_tag
                  windows/patchupmeterpreter/reverse_hop_http
                  windows/patchupmeterpreter/reverse_http
                  windows/patchupmeterpreter/reverse_http_proxy_pstore
                  windows/patchupmeterpreter/reverse_https
                  windows/patchupmeterpreter/reverse_https_proxy
                  windows/patchupmeterpreter/reverse_ipv6_tcp
                  windows/patchupmeterpreter/reverse_nonx_tcp
                  windows/patchupmeterpreter/reverse_ord_tcp
                  windows/patchupmeterpreter/reverse_tcp
                  windows/patchupmeterpreter/reverse_tcp_allports
                  windows/patchupmeterpreter/reverse_tcp_dns
                  windows/patchupmeterpreter/reverse_tcp_rc4
                  windows/patchupmeterpreter/reverse_tcp_rc4_dns
                  windows/patchupmeterpreter/reverse_tcp_uuid
                  windows/patchupmeterpreter/reverse_winhttp
                  windows/patchupmeterpreter/reverse_winhttps
                  windows/shell/bind_hidden_ipknock_tcp
                  windows/shell/bind_hidden_tcp
                  windows/shell/bind_ipv6_tcp
                  windows/shell/bind_ipv6_tcp_uuid
                  windows/shell/bind_nonx_tcp
                  windows/shell/bind_tcp
                  windows/shell/bind_tcp_rc4
                  windows/shell/bind_tcp_uuid
                  windows/shell/find_tag
                  windows/shell/reverse_hop_http
                  windows/shell/reverse_http
                  windows/shell/reverse_http_proxy_pstore
                  windows/shell/reverse_https
                  windows/shell/reverse_https_proxy
                  windows/shell/reverse_ipv6_tcp
                  windows/shell/reverse_nonx_tcp
                  windows/shell/reverse_ord_tcp
                  windows/shell/reverse_tcp
                  windows/shell/reverse_tcp_allports
                  windows/shell/reverse_tcp_dns
                  windows/shell/reverse_tcp_rc4
                  windows/shell/reverse_tcp_rc4_dns
                  windows/shell/reverse_tcp_uuid
                  windows/shell/reverse_winhttp
                  windows/shell/reverse_winhttps
                  windows/upexec/bind_hidden_ipknock_tcp
                  windows/upexec/bind_hidden_tcp
                  windows/upexec/bind_ipv6_tcp
                  windows/upexec/bind_ipv6_tcp_uuid
                  windows/upexec/bind_nonx_tcp
                  windows/upexec/bind_tcp
                  windows/upexec/bind_tcp_rc4
                  windows/upexec/bind_tcp_uuid
                  windows/upexec/find_tag
                  windows/upexec/reverse_hop_http
                  windows/upexec/reverse_http
                  windows/upexec/reverse_http_proxy_pstore
                  windows/upexec/reverse_https
                  windows/upexec/reverse_https_proxy
                  windows/upexec/reverse_ipv6_tcp
                  windows/upexec/reverse_nonx_tcp
                  windows/upexec/reverse_ord_tcp
                  windows/upexec/reverse_tcp
                  windows/upexec/reverse_tcp_allports
                  windows/upexec/reverse_tcp_dns
                  windows/upexec/reverse_tcp_rc4
                  windows/upexec/reverse_tcp_rc4_dns
                  windows/upexec/reverse_tcp_uuid
                  windows/upexec/reverse_winhttp
                  windows/upexec/reverse_winhttps
                  windows/vncinject/bind_hidden_ipknock_tcp
                  windows/vncinject/bind_hidden_tcp
                  windows/vncinject/bind_ipv6_tcp
                  windows/vncinject/bind_ipv6_tcp_uuid
                  windows/vncinject/bind_nonx_tcp
                  windows/vncinject/bind_tcp
                  windows/vncinject/bind_tcp_rc4
                  windows/vncinject/bind_tcp_uuid
                  windows/vncinject/find_tag
                  windows/vncinject/reverse_hop_http
                  windows/vncinject/reverse_http
                  windows/vncinject/reverse_http_proxy_pstore
                  windows/vncinject/reverse_https
                  windows/vncinject/reverse_https_proxy
                  windows/vncinject/reverse_ipv6_tcp
                  windows/vncinject/reverse_nonx_tcp
                  windows/vncinject/reverse_ord_tcp
                  windows/vncinject/reverse_tcp
                  windows/vncinject/reverse_tcp_allports
                  windows/vncinject/reverse_tcp_dns
                  windows/vncinject/reverse_tcp_rc4
                  windows/vncinject/reverse_tcp_rc4_dns
                  windows/vncinject/reverse_tcp_uuid
                  windows/vncinject/reverse_winhttp
                  windows/vncinject/reverse_winhttps
                  bsd/x86/shell/bind_ipv6_tcp
                  bsd/x86/shell/bind_tcp
                  bsd/x86/shell/find_tag
                  bsd/x86/shell/reverse_ipv6_tcp
                  bsd/x86/shell/reverse_tcp
                  bsdi/x86/shell/bind_tcp
                  bsdi/x86/shell/reverse_tcp
                  linux/armle/shell/bind_tcp
                  linux/armle/shell/reverse_tcp
                  linux/mipsbe/shell/reverse_tcp
                  linux/mipsle/shell/reverse_tcp
                  linux/x64/shell/bind_tcp
                  linux/x64/shell/reverse_tcp
                  linux/x86/meterpreter/bind_ipv6_tcp
                  linux/x86/meterpreter/bind_ipv6_tcp_uuid
                  linux/x86/meterpreter/bind_nonx_tcp
                  linux/x86/meterpreter/bind_tcp
                  linux/x86/meterpreter/bind_tcp_uuid
                  linux/x86/meterpreter/find_tag
                  linux/x86/meterpreter/reverse_ipv6_tcp
                  linux/x86/meterpreter/reverse_nonx_tcp
                  linux/x86/meterpreter/reverse_tcp
                  linux/x86/meterpreter/reverse_tcp_uuid
                  linux/x86/shell/bind_ipv6_tcp
                  linux/x86/shell/bind_ipv6_tcp_uuid
                  linux/x86/shell/bind_nonx_tcp
                  linux/x86/shell/bind_tcp
                  linux/x86/shell/bind_tcp_uuid
                  linux/x86/shell/find_tag
                  linux/x86/shell/reverse_ipv6_tcp
                  linux/x86/shell/reverse_nonx_tcp
                  linux/x86/shell/reverse_tcp
                  linux/x86/shell/reverse_tcp_uuid
                  osx/armle/execute/bind_tcp
                  osx/armle/execute/reverse_tcp
                  osx/armle/shell/bind_tcp
                  osx/armle/shell/reverse_tcp
                  osx/ppc/shell/bind_tcp
              }

              run_counter = Metasploit::Cache::Spec::RunCounter.new max: 5

              payload_staged_reference_names.each do |reference_name|
                reference_name_context 'payload',
                                       reference_name,
                                       run_counter: run_counter
              end
            end
          end

          include_examples 'can use full names',
                           'post',
                           max_run_count: 5,
                           pending_reason_by_reference_name: {
                               'firefox/gather/cookies' => 'Missing platforms',
                               'firefox/gather/history' => 'Missing platforms',
                               'firefox/gather/passwords' => 'Missing platforms',
                               'firefox/manage/webcam_chat' => 'Missing platforms',
                               'windows/gather/credentials/spark_im' => 'Missing platforms',
                               'windows/gather/netlm_downgrade' => 'Missing platforms',
                           }
        end
      end
    end
  end
end