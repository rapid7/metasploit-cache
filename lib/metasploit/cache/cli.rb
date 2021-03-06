require 'erb'
require 'ruby-progressbar'
require 'transaction_retry'

# Command-line interface (CLI) for metasploit-cache
class Metasploit::Cache::CLI < Thor
  extend ActiveSupport::Autoload

  autoload :Framework
  autoload :LoggerFormatter
  autoload :ProgressBarOutput

  #
  # CONSTANTS
  #

  # Maps module type to config used for {#use}.
  CONFIG_BY_MODULE_TYPE = {
      'auxiliary' => {
          instance: :auxiliary_instance,
          instance_persister_class: Metasploit::Cache::Auxiliary::Instance::Persister
      },
      'encoder' => {
          instance: :encoder_instance,
          instance_persister_class: Metasploit::Cache::Encoder::Instance::Persister
      },
      'exploit' => {
          instance: :exploit_instance,
          instance_persister_class: Metasploit::Cache::Exploit::Instance::Persister
      },
      'nop' => {
          instance: :nop_instance,
          instance_persister_class: Metasploit::Cache::Nop::Instance::Persister
      },
      'post' => {
          instance: :post_instance,
          instance_persister_class: Metasploit::Cache::Post::Instance::Persister
      }
  }

  # Maps type directory to config used for {#load_type_directory}.
  CONFIG_BY_TYPE_DIRECTORY = {
      'auxiliary' => {
          ancestor_persister_class: Metasploit::Cache::Module::Ancestor::Persister,
          ancestors: :auxiliary_ancestors,
          build_class: :build_auxiliary_class,
          build_instance: :build_auxiliary_instance,
          instance_persister_class: Metasploit::Cache::Auxiliary::Instance::Persister
      },
      'encoders' => {
          ancestor_persister_class: Metasploit::Cache::Module::Ancestor::Persister,
          ancestors: :encoder_ancestors,
          build_class: :build_encoder_class,
          build_instance: :build_encoder_instance,
          instance_persister_class: Metasploit::Cache::Encoder::Instance::Persister
      },
      'exploits' => {
          ancestor_persister_class: Metasploit::Cache::Module::Ancestor::Persister,
          ancestors: :exploit_ancestors,
          build_class: :build_exploit_class,
          build_instance: :build_exploit_instance,
          instance_persister_class: Metasploit::Cache::Exploit::Instance::Persister
      },
      'nops' => {
          ancestor_persister_class: Metasploit::Cache::Module::Ancestor::Persister,
          ancestors: :nop_ancestors,
          build_class: :build_nop_class,
          build_instance: :build_nop_instance,
          instance_persister_class: Metasploit::Cache::Nop::Instance::Persister
      },
      'payloads/singles' => {
          ancestor_persister_class: Metasploit::Cache::Module::Ancestor::Persister,
          ancestors: :single_payload_ancestors,
          build_class: :build_payload_single_unhandled_class,
          build_instance: :build_payload_single_unhandled_instance,
          instance_persister_class: Metasploit::Cache::Payload::Single::Unhandled::Instance::Persister
      },
      'payloads/stages' => {
          ancestor_persister_class: Metasploit::Cache::Module::Ancestor::Persister,
          ancestors: :stage_payload_ancestors,
          build_class: :build_stage_payload_class,
          build_instance: :build_payload_stage_instance,
          instance_persister_class: Metasploit::Cache::Payload::Stage::Instance::Persister
      },
      'payloads/stagers' => {
          ancestor_persister_class: Metasploit::Cache::Payload::Stager::Ancestor::Persister,
          ancestors: :stager_payload_ancestors,
          build_class: :build_stager_payload_class,
          build_instance: :build_payload_stager_instance,
          instance_persister_class: Metasploit::Cache::Payload::Stager::Instance::Persister
      },
      'post' => {
          ancestor_persister_class: Metasploit::Cache::Module::Ancestor::Persister,
          ancestors: :post_ancestors,
          build_class: :build_post_class,
          build_instance: :build_post_instance,
          instance_persister_class: Metasploit::Cache::Post::Instance::Persister
      }
  }

  # Supported directories from which to loaded Metasploit Modules into cache.
  TYPE_DIRECTORIES = %w{auxiliary encoders exploits nops payloads/singles payloads/stages payloads/stagers post}

  #
  # Class Methods
  #

  # Tagged logger that works with STDOUT.
  #
  # @return [ActiveSupport::TaggedLogging]
  def self.tagged_logger(severity)
    logger = Logger.new(STDOUT)
    logger.level = Logger.const_get(severity)
    logger.formatter = Metasploit::Cache::CLI::LoggerFormatter.new

    ActiveSupport::TaggedLogging.new(logger)

    logger.formatter.extend Metasploit::Cache::CLI::LoggerFormatter::TaggedBacktrace

    logger
  end

  #
  # Class options
  #

  class_option :include,
               default: [],
               desc: 'Specify $LOAD_PATH directory',
               type: :array
  class_option :database_yaml,
               desc: 'Path to database.yml contain configuration to establish ActiveRecord::Base connection'
  class_option :environment,
               desc: 'Environment to use from DATABASE_YAML'
  class_option :logger_severity,
               default: 'DEBUG',
               desc: 'The log level (from least to most severe: DEBUG, INFO, WARN, ERROR, FATAL)'
  class_option :require,
               default: [],
               desc: 'Require library before loading modules',
               type: :array

  #
  # Commands
  #

  desc 'load MODULE_PATH',
       'Loads metadata about the Metasploit Module instances from the given load path into the database'
  option :assume_changed,
         default: false,
         desc: 'If `true`, assume the `Metasploit::Cache::Module::Ancestor#real_path_modified_at` and ' \
               '`Metasploit::Cache::Module::Ancestor#real_path_sha1_hex_digest` have changed and reloading should ' \
               'occur',
         type: :boolean
  option :concurrent,
         default: false,
         desc: 'Load type directories concurrently',
         type: :boolean
  option :gem,
         desc: 'The name of the gem that is adding this module path to metasploit-framework. For paths normally ' \
               "added by metasploit-framework itself, this would be `'metasploit-framework'`, while for Metasploit " \
               "Pro this would be `'metasploit-pro'`. GEM does not have to be a gem on rubygems, it just functions " \
               'as a namespace for NAME so that projects using metasploit-framework do not need to worry about ' \
               'collisions on NAME which could disrupt the cache behavior.'
  option :only_type_directories,
         desc: "Only load the given type directories ('auxiliary', 'encoders', 'exploits', 'nops', " \
               "'payloads/singles', 'payloads/stages', 'payloads/stagers', 'post')",
         type: :array
  option :staged_payloads,
         default: true,
         desc: 'If `true`, then attempt to load staged payloads from the already loaded stage and stager payloads. ' \
               '(If the database is not populated yet, and you run with `--only-type-directories`, you need to run ' \
                'with at least `--only-type-directories payloads/stages payloads/stagers`.) ' \
               'If `false`, only load stage and stagers without combining into staged payloads.'
  option :name,
         desc: 'The name of the module path scoped to GEM.  GEM and NAME uniquely identify this path so that ' \
               'if MODULE_PATH changes, the entire cache does not need to be invalidated because the change in ' \
               'MODULE_PATH will still be tied to the same (GEM, NAME) tuple.'
  # Loads metadata about the Metasploit Module instances from the given load path into the database.
  #
  # @param path [String]
  # @return [void]
  def load(path)
    gem = options['gem']
    name = options['name']
    real_path = File.realpath(path)

    if (gem.nil? && !name.nil?) || (!gem.nil? && name.nil?)
      raise ArgumentError,
            "--gem and --name MUST be set together"
    end

    include_load_paths(options.fetch('include'))
    require_libraries(options.fetch('require'))

    tagged_logger = self.class.tagged_logger(options.fetch('logger_severity'))
    configure_i18n
    ActiveRecord::Base.logger = tagged_logger

    establish_connection(
        database_yaml_path: options.fetch('database_yaml'),
        environment: options.fetch('environment')
    )

    load_seeds

    module_path = Metasploit::Cache::Module::Path.resolve_collisions(
        gem: gem,
        name: name,
        real_path: real_path
    )

    type_directories = filtered_type_directories
    metasploit_framework = metasploit_framework_double

    status = 0

    if options.fetch('concurrent')
      threads = type_directories.map { |type_directory|
        # self must be passed first so load_type_directory is bound to it
        Thread.new self,
                   module_path,
                   type_directory,
                   assume_changed: options.fetch('assume_changed'),
                   metasploit_framework: metasploit_framework,
                   logger: tagged_logger,
                   &:load_type_directory
      }

      threads.each do |thread|
        begin
          thread.join
        rescue Exception => exception
          tagged_logger.error(exception)
          status = 1
        end
      end
    else
      type_directories.each do |type_directory|
        begin
          load_type_directory(
              module_path,
              type_directory,
              assume_changed: options.fetch('assume_changed'),
              metasploit_framework: metasploit_framework,
              logger: tagged_logger,
          )
        rescue Exception => exception
          tagged_logger.error(exception)
          status = 1
        end
      end
    end

    if options.fetch('staged_payloads')
      load_staged_payloads(
          logger: tagged_logger,
          metasploit_framework: metasploit_framework
      )
    end

    exit(status)
  end

  desc 'seed',
       'Seed database with architectures, authorities, platforms, and ranks (run automatically as part of load)'
  # Seed database with architectures, authorities, platforms, and ranks (run automatically as part of load).
  #
  # @return [void]
  def seed
    establish_connection(
        database_yaml_path: options.fetch('database_yaml'),
        environment: options.fetch('environment')
    )

    load_seeds
  end

  desc 'use',
       'Simulate `use FULL_NAME` by loading the Metasploit Module class with the given FULL_NAME using ' \
       'Metasploit::Cache::Module::Class::Name look-up and then try to initiate the Metasploit Module class into a ' \
       'Metasploit Module instance'
  # Simulate `use FULL_NAME` by loading the Metasploit Module class with the given FULL_NAME using
  # {Metasploit::Cache::Module::Class::Name} look-up and then try to initiate the Metasploit Module class into a
  # Metasploit Module instance.
  #
  # @param full_name [String] a Metasploit Module full name composed of `<module_type>/<reference_name>`.
  # @return [void]
  def use(full_name)
    include_load_paths(options.fetch('include'))
    require_libraries(options.fetch('require'))

    tagged_logger = self.class.tagged_logger(options.fetch('logger_severity'))
    configure_i18n
    ActiveRecord::Base.logger = tagged_logger

    establish_connection(
        database_yaml_path: options.fetch('database_yaml'),
        environment: options.fetch('environment')
    )

    module_type, reference_name = full_name.split('/', 2)

    module_class_name = Metasploit::Cache::Module::Class::Name.where(module_type: module_type, reference: reference_name).first

    if module_class_name.nil?
      tagged_logger.error {
        "No Metasploit::Cache::Module::Class::Name found with module_type (#{module_type}) and " \
        "reference (#{reference_name})"
      }

      exit(1)
    end

    module_class = module_class_name.module_class

    if module_class.is_a? Metasploit::Cache::Payload::Staged::Class
      use_staged_instance module_class,
                          logger: tagged_logger
    else
      use_unstaged_instance module_class,
                            logger: tagged_logger
    end

    tagged_logger.info {
      "#{full_name} is usable"
    }
  end

  #
  # Instance Methods
  #

  no_commands do
    # @api private
    # @note Must be public to be used as a block to `Thread.new`, but should be considered a private API.
    #
    # Loads Metasploit Module instances under `type_directory` under `module_path`.
    #
    # @param module_path [Metasploit::Cache::Module::Path]
    # @param type_directory [String]
    # @param assume_changed [Boolean] (false) whether to assume that files have changed and reload the module ancestors.
    # @param logger [ActiveSupport::TaggedLogging]
    # @param metasploit_framework
    # @return [void]
    def load_type_directory(module_path, type_directory, assume_changed:, logger:, metasploit_framework:)
      config = CONFIG_BY_TYPE_DIRECTORY.fetch(type_directory)

      ancestors = module_path.public_send(config.fetch(:ancestors))

      output = Metasploit::Cache::CLI::ProgressBarOutput.new(logger)
      progress_bar = ProgressBar.create(
          format: "[%t] %c / %C (%p%%) after %a",
          output: output,
          title: type_directory
      )

      ancestors.each_changed(assume_changed: assume_changed, progress_bar: progress_bar) do |module_ancestor|
        module_ancestor_load = Metasploit::Cache::Module::Ancestor::Load.new(
            logger: logger,
            maximum_version: Metasploit::Framework::Version::MAJOR,
            module_ancestor: module_ancestor,
            persister_class: config.fetch(:ancestor_persister_class)
        )

        unless module_ancestor_load.valid?
          logger.error {
            "#{module_ancestor_load.class} is invalid: #{module_ancestor_load.errors.full_messages.to_sentence}"
          }

          next
        end

        module_class = module_ancestor.public_send(config.fetch(:build_class))

        if module_class.is_a? Metasploit::Cache::Payload::Unhandled::Class
          module_class_load = Metasploit::Cache::Payload::Unhandled::Class::Load.new(
              logger: logger,
              metasploit_module: module_ancestor_load.metasploit_module,
              payload_unhandled_class: module_class,
              payload_superclass: Msf::Payload
          )
        else
          module_class_load = Metasploit::Cache::Direct::Class::Load.new(
              direct_class: module_class,
              logger: logger,
              metasploit_module: module_ancestor_load.metasploit_module
          )
        end

        unless module_class_load.valid?
          logger.error {
            "#{module_class_load.class} is invalid: #{module_class_load.errors.full_messages.to_sentence}"
          }

          next
        end

        module_instance = module_class.public_send(config.fetch(:build_instance))

        module_instance_load = Metasploit::Cache::Module::Instance::Load.new(
            persister_class: config.fetch(:instance_persister_class),
            logger: logger,
            metasploit_framework: metasploit_framework,
            metasploit_module_class: module_class_load.metasploit_class,
            module_instance: module_instance
        )

        unless module_instance_load.valid?
          logger.error {
            "#{module_instance_load.class} is invalid: #{module_instance_load.errors.full_messages.to_sentence}"
          }

          next
        end

        if module_instance.is_a? Metasploit::Cache::Payload::Single::Unhandled::Instance
          payload_single_handled_class = module_instance.build_payload_single_handled_class

          payload_single_handled_class_load = Metasploit::Cache::Payload::Single::Handled::Class::Load.new(
              handler_module: module_instance_load.metasploit_module_instance.handler_klass,
              logger: logger,
              metasploit_module: module_ancestor_load.metasploit_module,
              payload_single_handled_class: payload_single_handled_class,
              payload_superclass: Msf::Payload
          )

          unless payload_single_handled_class_load.valid?
            logger.error {
              "#{payload_single_handled_class_load.class} is invalid: #{payload_single_handled_class_load.errors.full_messages.to_sentence}"
            }

            next
          end

          payload_single_handled_instance = payload_single_handled_class.build_payload_single_handled_instance

          payload_single_handled_instance_load = Metasploit::Cache::Module::Instance::Load.new(
              persister_class: Metasploit::Cache::Payload::Single::Handled::Instance::Persister,
              logger: logger,
              metasploit_framework: metasploit_framework,
              metasploit_module_class: payload_single_handled_class_load.metasploit_class,
              module_instance: payload_single_handled_instance
          )

          unless payload_single_handled_instance_load.valid?
            logger.error {
              "#{payload_single_handled_instance_load.class} is invalid: #{payload_single_handled_instance_load.errors.full_messages.to_sentence}"
            }

            next
          end
        end
      end
    end
  end

  private

  # Adds metasploit-cache's i18n files to `I18n.load_path`
  #
  # @return [void]
  def configure_i18n
    I18n.load_path += Dir[self.class.root_pathname.join('config', 'locales', '*.{rb,yml}')]
  end

  # Establishes an `ActiveRecord::Base` connection by looking up configuration for `environment` in
  # `database_yaml_path`, which is preprocessed with ERB before loading as YAML.
  #
  # @param database_yaml_path [String] path to `database.yml`.
  # @param environment [String] environment name in `database.yml`.
  # @return [void]
  def establish_connection(database_yaml_path:, environment:)
    erb_template = File.read(database_yaml_path)
    configuration = YAML.load(ERB.new(erb_template).result)
    ActiveRecord::Base.establish_connection(configuration.fetch(environment))

    TransactionRetry.apply_activerecord_patch
    TransactionRetry.max_retries = TYPE_DIRECTORIES.length
  end

  # Filters {TYPE_DIRECTORIES} based on `--only-type-directories` arguments.
  #
  # @return [Array<String>] {TYPE_DIRECTORIES} if `--only-type-directories` is not given, otherwise Array of type
  #   directories passed to `--only-type-directories`.
  # @raise [ArgumentError] if argument to `--only-type-directories` is not in {TYPE_DIRECTORIES}.
  def filtered_type_directories
    only_type_directries = options['only_type_directories']

    if only_type_directries
      type_directories = []
      only_type_directries.each do |type_directory|
        if TYPE_DIRECTORIES.include? type_directory
          type_directories << type_directory
        else
          raise ArgumentError,
                "Argument passed to --only-type-directory (#{type_directory}) is not a valid type directory " \
                "(#{TYPE_DIRECTORIES.to_sentence})"
        end
      end
    else
      type_directories = TYPE_DIRECTORIES
    end

    type_directories
  end

  # Adds `load_paths` to front of `$LOAD_PATH` if the load path isn't already in `$LOAD_PATH`.
  #
  # @param load_paths [Array<String>] Array of file paths.
  # @return [void]
  def include_load_paths(load_paths)
    load_paths.each do |load_path|
      expanded_load_path = File.expand_path(load_path)

      unless $LOAD_PATH.include? expanded_load_path
        $LOAD_PATH.unshift expanded_load_path
      end
    end
  end

  # Loads {Metasploit::Cache::Payload::Staged::Instance}s from compatible
  # {Metasploit::Cache::Payload::Stage::Instance}s and {Metasploit::Cache::Payload::Stager::Instances}.
  #
  # @param logger [ActiveSupport::TaggedLogging]
  # @param metasploit_framework
  def load_staged_payloads(logger:, metasploit_framework:)
    payload_stage_instances = Metasploit::Cache::Payload::Stage::Instance.all.to_a
    payload_stage_instance_count = Metasploit::Cache::Payload::Stage::Instance.count

    payload_stager_instances = Metasploit::Cache::Payload::Stager::Instance.all.to_a
    payload_stager_instance_count = Metasploit::Cache::Payload::Stager::Instance.count

    output = Metasploit::Cache::CLI::ProgressBarOutput.new(logger)
    progress_bar = ProgressBar.create(
        format: "[%t] %c / %C (%p%%) after %a",
        output: output,
        title: 'staged payloads'
    )
    progress_bar.total = payload_stage_instance_count * payload_stager_instance_count

    payload_stage_instances.each do |payload_stage_instance|
      payload_stage_ancestor = payload_stage_instance.payload_stage_class.ancestor
      payload_stage_real_path = payload_stage_ancestor.real_pathname.to_s

      logger.tagged(payload_stage_real_path) do |payload_stage_logger|
        payload_stage_metasploit_module = module_ancestor_metasploit_module(payload_stage_ancestor)

        payload_stager_instances.each do |payload_stager_instance|
          payload_stager_ancestor = payload_stager_instance.payload_stager_class.ancestor
          payload_stager_real_path = payload_stager_ancestor.real_pathname.to_s

          payload_stage_logger.tagged(payload_stager_real_path) do |payload_staged_logger|
            payload_stager_handler_module = payload_stager_instance.handler.name.constantize
            payload_stager_metasploit_module = module_ancestor_metasploit_module(payload_stager_ancestor)

            load_staged_payload(
                logger: payload_staged_logger,
                metasploit_framework: metasploit_framework,
                payload_stage_instance: payload_stage_instance,
                payload_stage_metasploit_module: payload_stage_metasploit_module,
                payload_stager_handler_module: payload_stager_handler_module,
                payload_stager_instance: payload_stager_instance,
                payload_stager_metasploit_module: payload_stager_metasploit_module
            )

            progress_bar.increment
          end
        end
      end
    end
  end

  # @param logger [ActiveSupport::TaggedLogging]
  # @param metasploit_framework
  # @param payload_stage_instance [Metasploit::Cache::Payload::Stage::Instance]
  # @param payload_stager_instance [Metasploit::Cache::Paylaod::Stager::Instance]
  def load_staged_payload(
      logger:,
      metasploit_framework:,
      payload_stage_instance:,
      payload_stage_metasploit_module:,
      payload_stager_handler_module:,
      payload_stager_instance:,
      payload_stager_metasploit_module:
  )
    payload_staged_class = Metasploit::Cache::Payload::Staged::Class.new(
        payload_stage_instance: payload_stage_instance,
        payload_stager_instance: payload_stager_instance
    )

    unless payload_staged_class.compatible?
      # only info because a lot of staged classes are expected to have incompatibilities
      logger.info "Incompatible architectures or platforms"

      return
    end

    payload_staged_class_load = Metasploit::Cache::Payload::Staged::Class::Load.new(
        # constantize cached name instead of using
        # `payload_stager_instance_load.metasploit_module_instance.handler_klass` to prove handler can be
        # loaded directly from cache without the need to load the payload_stager_instance on reboot
        handler_module: payload_stager_handler_module,
        logger: logger,
        payload_stage_metasploit_module: payload_stage_metasploit_module,
        payload_staged_class: payload_staged_class,
        payload_stager_metasploit_module: payload_stager_metasploit_module,
        payload_superclass: Msf::Payload
    )

    unless payload_staged_class_load.valid?
      logger.error {
        "#{payload_staged_class_load.class} is invalid: #{payload_staged_class_load.errors.full_messages.to_sentence}"
      }
      
      return
    end
    
    payload_staged_instance = payload_staged_class.build_payload_staged_instance

    payload_staged_instance_load = Metasploit::Cache::Module::Instance::Load.new(
        persister_class: Metasploit::Cache::Payload::Staged::Instance::Persister,
        logger: logger,
        metasploit_framework: metasploit_framework,
        metasploit_module_class: payload_staged_class_load.metasploit_class,
        module_instance: payload_staged_instance
    )

    unless payload_staged_instance_load.valid?
      logger.error {
        "#{payload_staged_instance_load.instance} is invalid: #{payload_staged_instance_load.errors.full_messages.to_sentence}"
      }
    end
  end

  # @note No on-demand loading occurs.  The ruby Class or Module must have been previously loaded for this method NOT to
  #   return `nil`.
  #
  # The Metasploit Module ruby Class or Module defined in the {Metasploit::Cache::Module::Ancestor#real_pathname}.
  #
  # @param module_ancestor [Metasploit::Cache::Module::Ancestor, #real_path_sha1_hex_digest]
  # @return [Module] a `Module` or `Class` from the {Metasploit::Cache::Module::Ancestor#real_pathname}
  # @return [nil] if {#module_ancestor_module_namespace} is `nil`
  def module_ancestor_metasploit_module(module_ancestor)
    namespace_module = module_ancestor_module_namespace(module_ancestor)

    if namespace_module
      namespace_module.load.metasploit_module
    end
  end

  # The parent namespace Module of the ruby Class or Module defined in
  # {Metasploit::Cache::Module::Ancestor#real_pathname}.
  #
  # @return [Module] a ruby Module that acts as the implicit namespace for a Metasploit Module's ruby Class or Module.
  # @return [nil] if {Metasploit::Cache::Module::Namespace.names} does not resolve to a loaded ruby Module.
  def module_ancestor_module_namespace(module_ancestor)
    names = Metasploit::Cache::Module::Namespace.names(module_ancestor)

    Metasploit::Cache::Constant.current(names)
  end

  # Root directory for metasploit-cache.
  #
  # @return [Pathname]
  def self.root_pathname
    @root_pathname ||= Pathname.new("../../../..").expand_path(__FILE__)
  end

  # @note Connection must be established first
  #
  # Loads architecture, authority, platform, and rank seeds.
  #
  # @return [void]
  def load_seeds
    Kernel.load self.class.root_pathname.join("db/seeds.rb").to_path
  end

  # Returns a fake `Msf::Simple::Framework` with enough of the API to load Metasploit Modules into the cache.
  #
  # @return [Metasploit::Cache::CLI::Framework, <Hash>#datastore]
  def metasploit_framework_double
    Metasploit::Cache::CLI::Framework.new
  end

  # Requires the libraries.
  #
  # @param libraries [Array<String>] Array of library names to `require`
  # @return [void]
  def require_libraries(libraries)
    libraries.each do |library|
      require library
    end
  end

  # @note Will exit on errors.
  #
  # Validates `active_model`.  If `active_model` is invalid, logs validation error full messages as a sentence and exit
  # with `exit_code`.
  #
  # @param active_model [#errors, #valid?] model to validate
  # @param exit_code [Integer] Code passed to `exit` when `active_model` is invalid
  # @param logger [ActiveSupport::TaggedLogging]
  # @return [void]
  def exit_unless_valid(active_model, exit_code, logger:)
    unless active_model.valid?
      logger.error {
        "#{active_model.class} is invalid: #{active_model.errors.full_messages.to_sentence}"
      }

      exit(exit_code)
    end
  end

  # @note Will exit on errors.
  #
  # Loads the stage and stage ancestors before loading the staged class and instance.
  #
  # @param payload_staged_class [Metasploit::Cache::Payload::Staged::Class]
  # @param logger [ActiveSupport::TaggedLogging]
  # @return [void]
  def use_staged_instance(payload_staged_class, logger:)
    payload_stage_ancestor = payload_staged_class.payload_stage_instance.payload_stage_class.ancestor

    payload_stage_ancestor_load = Metasploit::Cache::Module::Ancestor::Load.new(
        logger: logger,
        maximum_version: Metasploit::Framework::Version::MAJOR,
        module_ancestor: payload_stage_ancestor,
        persister_class: Metasploit::Cache::Module::Ancestor::Persister
    )

    exit_unless_valid payload_stage_ancestor_load,
                      2,
                      logger: logger

    payload_stager_ancestor = payload_staged_class.payload_stager_instance.payload_stager_class.ancestor

    payload_stager_ancestor_load = Metasploit::Cache::Module::Ancestor::Load.new(
        logger: logger,
        maximum_version: Metasploit::Framework::Version::MAJOR,
        module_ancestor: payload_stager_ancestor,
        persister_class: Metasploit::Cache::Payload::Stager::Ancestor::Persister
    )

    exit_unless_valid payload_stager_ancestor_load,
                      3,
                      logger: logger

    payload_staged_class_load = Metasploit::Cache::Payload::Staged::Class::Load.new(
        handler_module: payload_staged_class.payload_stager_instance.handler.name.constantize,
        logger: logger,
        payload_stage_metasploit_module: payload_stage_ancestor_load.metasploit_module,
        payload_staged_class: payload_staged_class,
        payload_stager_metasploit_module: payload_stager_ancestor_load.metasploit_module,
        payload_superclass: Msf::Payload
    )

    exit_unless_valid payload_staged_class_load,
                      4,
                      logger: logger

    payload_staged_instance = payload_staged_class.payload_staged_instance

    payload_staged_instance_load = Metasploit::Cache::Module::Instance::Load.new(
        logger: logger,
        metasploit_framework: metasploit_framework_double,
        metasploit_module_class: payload_staged_class_load.metasploit_class,
        module_instance: payload_staged_instance,
        persister_class: Metasploit::Cache::Payload::Staged::Instance::Persister
    )

    exit_unless_valid payload_staged_instance_load,
                      5,
                      logger: logger
  end

  # @note Will exit on errors.
  #
  # Loads the ancestor, class, and instance.
  #
  # @param module_class [Metasploit::Cache::Auxiliary::Class, Metasploit::Cache::Encoder::Class,
  #                      Metasploit::Cache::Exploit::Class, Metasploit::Cache::Nop::Class,
  #                      Metasploit::Cache::Payload::Single::Handled::Class, Metasploit::Cache::Post::Class]
  # @param logger [ActiveSupport::TaggedLogger]
  # @return [void]
  def use_unstaged_instance(module_class, logger:)
    if module_class.respond_to? :ancestor
      module_ancestor = module_class.ancestor
    else
      module_ancestor = module_class.payload_single_unhandled_instance.payload_single_unhandled_class.ancestor
    end

    module_ancestor_load = Metasploit::Cache::Module::Ancestor::Load.new(
        logger: logger,
        maximum_version: Metasploit::Framework::Version::MAJOR,
        module_ancestor: module_ancestor,
        persister_class: Metasploit::Cache::Module::Ancestor::Persister
    )

    exit_unless_valid module_ancestor_load,
                      2,
                      logger: logger

    if module_class.is_a? Metasploit::Cache::Direct::Class
      direct_class = module_class

      direct_class_load = Metasploit::Cache::Direct::Class::Load.new(
          direct_class: direct_class,
          logger: logger,
          metasploit_module: module_ancestor_load.metasploit_module
      )

      exit_unless_valid direct_class_load,
                        3,
                        logger: logger

      config = CONFIG_BY_MODULE_TYPE.fetch(module_class.name.module_type)
      module_instance = direct_class.public_send(config.fetch(:instance))

      module_instance_load = Metasploit::Cache::Module::Instance::Load.new(
          persister_class: config.fetch(:instance_persister_class),
          logger: logger,
          metasploit_framework: metasploit_framework_double,
          metasploit_module_class: direct_class_load.metasploit_class,
          module_instance: module_instance
      )

      exit_unless_valid module_instance_load,
                        4,
                        logger: logger
    else
      payload_single_handled_class = module_class

      payload_single_handled_class_load = Metasploit::Cache::Payload::Single::Handled::Class::Load.new(
          handler_module: payload_single_handled_class.payload_single_unhandled_instance.handler.name.constantize,
          logger: logger,
          metasploit_module: module_ancestor_load.metasploit_module,
          payload_single_handled_class: payload_single_handled_class,
          payload_superclass: Msf::Payload
      )

      exit_unless_valid payload_single_handled_class_load,
                        3,
                        logger: logger

      payload_single_unhandled_instance = payload_single_handled_class.payload_single_unhandled_instance

      payload_single_handled_instance_load = Metasploit::Cache::Module::Instance::Load.new(
          persister_class: Metasploit::Cache::Payload::Single::Handled::Instance::Persister,
          logger: logger,
          metasploit_framework: metasploit_framework_double,
          metasploit_module_class: payload_single_handled_class_load.metasploit_class,
          module_instance: payload_single_unhandled_instance
      )

      exit_unless_valid payload_single_handled_instance_load,
                        4,
                        logger: logger
    end
  end
end