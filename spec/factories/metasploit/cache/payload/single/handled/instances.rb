FactoryGirl.define do
  factory :metasploit_cache_payload_single_handled_instance,
          class: Metasploit::Cache::Payload::Single::Handled::Instance do
    transient do
      payload_single_handled_class_payload_single_unhandled_instance_handler_load_pathname nil
    end

    payload_single_handled_class {
      if payload_single_handled_class_payload_single_unhandled_instance_handler_load_pathname.nil?
        raise ArgumentError,
              ':payload_single_handled_class_payload_single_unhandled_instance_handler_load_pathname must be set for '\
              ':metasploit_cache_payload_single_handled_instance, so it can set ' \
              ':payload_single_unhandled_instance_handler_load_path for ' \
              ':metasploit_cache_payload_single_handled_class, so it can set :handler_load_pathname for ' \
              ':metasploit_cache_payload_handable_handler trait, so it can set :load_pathname for ' \
              ':metasploit_cache_payload_handler_module trait'
      end

      build(
          :metasploit_cache_payload_single_handled_class,
          payload_single_unhandled_instance_handler_load_pathname: payload_single_handled_class_payload_single_unhandled_instance_handler_load_pathname
      )
    }
  end
end