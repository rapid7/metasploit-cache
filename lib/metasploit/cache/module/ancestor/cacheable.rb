# Adds {#cache} to Metasploit Module.
module Metasploit::Cache::Module::Ancestor::Cacheable
  def cache
    @cache ||= Metasploit::Cache::Module::Ancestor::Cache.new(metasploit_module: self)
  end
end