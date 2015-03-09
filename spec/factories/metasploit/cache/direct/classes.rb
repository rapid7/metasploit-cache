FactoryGirl.define do
  #
  # Sequences
  #

  sequence :metasploit_cache_direct_class_factory,
           Metasploit::Cache::Direct::Class::Spec.random_factory
end