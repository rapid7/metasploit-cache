# Adds {#load Metasploit Module loading} to {Metasploit::Cache::Module::Namespace::CONTENT module namespace}.
module Metasploit::Cache::Module::Namespace::Loadable
  # @overload load(persister_class:)
  #   Creates a new {Metasploit::Cache::Module::Namespace::Load} with this Module as the
  #   {Metasploit::Cache::Module::Namespace::Load#module_namespace} and the passed `persister_class` as the
  #   {Metasploit::Cache::Module::Namespace::Load#persister_class}.
  #
  #   @return [Metasploit::Cache::Module::Ancestor::Load]
  #
  # @overload load
  #   @return [Metasploit::Cache::Module::Ancestor::Load] Previously created
  #     {Metasploit::Cache::Module::Namespace::Load}.
  def load(options={})
    if !instance_variable_defined?(:@load)
      @load = Metasploit::Cache::Module::Namespace::Load.new(
          module_namespace: self,
          persister_class: options.fetch(:persister_class)
      )
    else
      if !options.empty?
        raise ArgumentError,
              'Metasploit::Cache::Module::Namespace::Loadable#load already created: ' \
              "can't pass options (#{options.inspect})"
      end
    end

    @load
  end
end