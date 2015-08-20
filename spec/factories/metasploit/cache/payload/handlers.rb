FactoryGirl.define do
  #
  # Factories
  #

  factory :metasploit_cache_payload_handler,
          class: Metasploit::Cache::Payload::Handler do
    general_handler_type { generate :metasploit_cache_payload_handler_general_handler_type }
    handler_type { generate :metasploit_cache_payload_handler_handler_type }
    name { generate :metasploit_cache_payload_handler_name }

    factory :full_metasploit_cache_payload_handler,
            traits: [:metasploit_cache_payload_handler_module]
  end

  #
  # Sequences
  #

  sequence :metasploit_cache_payload_handler_general_handler_type,
           Metasploit::Cache::Spec.sample_stream(Metasploit::Cache::Payload::Handler::GeneralType::ALL)

  sequence :metasploit_cache_payload_handler_handler_type do |n|
    "metasploit_cache_payload_handler_handler_type#{n}"
  end

  handler_module_namespace = Metasploit::Cache::Payload::Handler::Namespace

  sequence(:metasploit_cache_payload_handler_name) { |n|
    "#{handler_module_namespace}::MetasploitCachePayloadHandler#{n}"
  }

  #
  # Traits
  #

  trait :metasploit_cache_payload_handler_module do
    transient do
      load_pathname nil
    end

    after(:build) do |payload_handler, evaluator|
      if evaluator.load_pathname.nil?
        raise ArgumentError,
              'load_path must be set for :metasploit_cache_payload_handler_module traits so the Module is written to ' \
              'a path that can be loaded with String#constantize'
      end

      namespace_name, _, module_name = payload_handler.name.rpartition('::')

      pathname = evaluator.load_pathname.join("#{module_name}.rb")

      Metasploit::Model::Spec::PathnameCollision.check!(pathname)

      cell = Metasploit::Cache::Payload::HandlerCell.(payload_handler)

      pathname.open('wb') do |f|
        f.write(
             cell.(:show)
        )
      end

      namespace = namespace_name.constantize

      namespace.autoload module_name, pathname.to_path
    end
  end
end