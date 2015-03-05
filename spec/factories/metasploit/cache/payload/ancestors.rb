FactoryGirl.define do
  sequence :metasploit_cache_payload_ancestor_factory,
           Metasploit::Cache::Payload::Ancestor::Spec.random_factory

  sequence :metasploit_cache_payload_ancestor_payload_name do |n|
    [
        'metasploit',
        'cache',
        'payload',
        'ancestor',
        'payload',
        "name#{n}"
    ].join('/')
  end

  trait :metasploit_cache_payload_ancestor do
    # first to allow overrides
    metasploit_cache_module_ancestor

    transient do
      module_type { 'payload' }
      payload_name { generate :metasploit_cache_payload_ancestor_payload_name }

      # depends on payload_name and payload_type
      reference_name {
        "#{payload_type.pluralize}/#{payload_name}"
      }
    end

  end
end