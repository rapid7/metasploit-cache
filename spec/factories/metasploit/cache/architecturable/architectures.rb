FactoryGirl.define do
  #
  # Factories
  #

  factory :metasploit_cache_architecturable_architecture,
          class: Metasploit::Cache::Architecturable::Architecture do
    # @note This factory is invalid unless `architecturable` is set by the caller
    architecturable { nil }

    architecture { generate :metasploit_cache_architecture }
  end
end