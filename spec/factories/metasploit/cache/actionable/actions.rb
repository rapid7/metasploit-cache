FactoryGirl.define do
  #
  # Factories
  #

  factory :metasploit_cache_actionable_action,
          class: Metasploit::Cache::Actionable::Action do
    # @note this factory is invalid unless caller sets actionable
    actionable nil

    name { generate :metasploit_cache_actionable_action_name }
  end

  #
  # Sequences
  #

  sequence :metasploit_cache_actionable_action_name do |n|
    "Metasploit::Cache::Actionable::Action#name #{n}"
  end
end