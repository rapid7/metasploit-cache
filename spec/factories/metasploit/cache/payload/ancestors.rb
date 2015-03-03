FactoryGirl.define do
  factory :metasploit_cache_payload_ancestor,
          class: Metasploit::Cache::Payload::Ancestor,
          parent: :metasploit_cache_module_ancestor do
    transient do
      module_type { 'payload' }
      payload_name { generate :metasploit_cache_payload_ancestor_payload_name }
      payload_type { generate :metasploit_cache_payload_ancestor_type }

      # depends on payload_name and payload_type
      reference_name {
        "#{payload_type.pluralize}/#{payload_name}"
      }
    end
  end

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
end