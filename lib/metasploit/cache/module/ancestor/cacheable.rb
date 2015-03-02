# Adds {#cache} to Metasploit Module.
module Metasploit::Cache::Module::Ancestor::Cacheable
  # Ephemeral cache for connecting this in-memory Metasploit Module to its persisted
  # {Metasploit::Cache::Module::Ancestor}.
  def cache
    @cache ||= Metasploit::Cache::Module::Ancestor::Cache.new(metasploit_module: self)
  end
end