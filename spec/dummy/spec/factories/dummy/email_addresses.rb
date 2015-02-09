FactoryGirl.define do
  factory :dummy_email_address,
          :class => Dummy::EmailAddress,
          :traits => [
              :metasploit_model_base,
              :metasploit_cache_email_address
          ]
end