# Adds {#cache cache metadata} to {Metasploit::Cache::Module::Namespace::CONTENT module namespace}.
module Metasploit::Cache::Module::Namespace::Cacheable
  # @return [Metasploit::Cache::Module::Ancestor::Cache]
  def cache
    @cache ||= Metasploit::Cache::Module::Namespace::Cache.new
  end
end