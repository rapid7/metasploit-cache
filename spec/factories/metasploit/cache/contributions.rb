FactoryGirl.define do
  #
  # Factories
  #

  factory :metasploit_cache_contribution,
          class: Metasploit::Cache::Contribution do
    # @note factory is invalid if caller does not set contributable
    contributable nil

    association :author, factory: :metasploit_cache_author
  end

  #
  # Traits
  #

  trait :metasploit_cache_contribution_email_address do
    association :email_address, factory: :metasploit_cache_email_address
  end
end