FactoryGirl.define do
  factory :metasploit_cache_payload_single_handled_class,
          class: Metasploit::Cache::Payload::Single::Handled::Class do
    transient do
      payload_single_unhandled_instance_handler_load_pathname nil
    end

    payload_single_unhandled_instance {
      if payload_single_unhandled_instance_handler_load_pathname.nil?
        raise ArgumentError,
              ':payload_single_unhandled_instance_handler_load_path must be set for ' \
              ':metasploit_cache_payload_single_handled_class so it can :handler_load_pathname for ' \
              ':metasploit_cache_payload_handable_handler trait so it can set :load_pathname for ' \
              ':metasploit_cache_payload_handler_module trait'
      end

      build(
          :full_metasploit_cache_payload_single_unhandled_instance,
          handler_load_pathname: payload_single_unhandled_instance_handler_load_pathname
      )
    }

    after(:build) do |payload_single_handled_class, _evaluator|
      payload_single_handled_class.build_name(
          module_type: 'payload',
          reference: payload_single_handled_class.reference_name

      )
    end
  end
end