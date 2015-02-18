# Adds {#load Metasploit Module loading} to {Metasploit::Cache::Module::Namespace::CONTENT module namespace}.
module Metasploit::Cache::Module::Namespace::Loadable
  # @return [Metasploit::Cache::Module::Ancestor::Load]
  def load
    @load ||= Metasploit::Cache::Module::Namespace::Load.new(module_namespace: self)
  end
end