FactoryGirl.define do
  #
  # Factories
  #

  factory :metasploit_cache_encoder_instance,
          class: Metasploit::Cache::Encoder::Instance do
    description { generate :metasploit_cache_encoder_instance_description }
    name { generate :metasploit_cache_encoder_instance_name }

    #
    # Associations
    #

    association :encoder_class, factory: :metasploit_cache_encoder_class
  end

  #
  # Sequences
  #

  sequence :metasploit_cache_encoder_instance_description do |n|
    "Metasploit::Cache::Encoder::Instance#description #{n}"
  end

  sequence :metasploit_cache_encoder_instance_name do |n|
    "Metasploit::Cache::Encoder::Instance#name #{n}"
  end
end