FactoryGirl.define do
  factory :metasploit_cache_payload_staged_instance,
          class: Metasploit::Cache::Payload::Staged::Instance do
    transient do
      payload_staged_class_payload_stager_instance_handler_load_pathname nil
    end

    payload_staged_class {
      if payload_staged_class_payload_stager_instance_handler_load_pathname.nil?
        raise ArgumentError,
              ':payload_staged_class_payload_stager_instance_handler_load_pathname must be set for ' \
              ':metasploit_cache_payload_staged_instance so it can set ' \
              ':payload_stager_instance_handler_load_pathname for :metasploit_cache_payload_staged_class so it can ' \
              'set :handler_load_pathname for :metasploit_cache_payload_handable_handler trait so it can set ' \
              ':load_pathname for :metasploit_cache_payload_handler_module trait'
      end

      create(
          :full_metasploit_cache_payload_staged_class,
          payload_stager_instance_handler_load_pathname: payload_staged_class_payload_stager_instance_handler_load_pathname
      )
    }
  end
end