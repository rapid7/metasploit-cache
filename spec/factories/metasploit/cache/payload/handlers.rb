FactoryGirl.define do
  #
  # Factories
  #

  factory :metasploit_cache_payload_handler,
          class: Metasploit::Cache::Payload::Handler do
    general_handler_type { generate :metasploit_cache_payload_handler_general_handler_type }
    handler_type { generate :metasploit_cache_payload_handler_handler_type }
  end

  #
  # Sequences
  #

  sequence :metasploit_cache_payload_handler_general_handler_type,
           Metasploit::Cache::Spec.sample_stream(Metasploit::Cache::Payload::Handler::GeneralType::ALL)

  sequence :metasploit_cache_payload_handler_handler_type do |n|
    "metasploit_cache_payload_handler_handler_type#{n}"
  end
end