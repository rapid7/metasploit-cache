# Adds {#ephemeral_cache_by_source} to Metasploit Module.
module Metasploit::Cache::Module::Ancestor::Cacheable
  # Ephemeral cache by the source the cached metadata.
  #
  # # Non-payload
  #
  # For non-payload Metasploit Module, the {Metasploit::Cache::Module::Ancestor#real_pathname} contains a ruby Class,
  # so all three sources will be attached to the Metasploit Module directly:
  # * `:ancestor` - metadata gathered from the {Metasploit::Cache::Module::Ancestor::Load}
  # * `:class` - metadata gathered from the {Metasploit::Cache::Module::Class::Load} from `Class` constants or methods.
  # * `:instance` - metadata gathered from the {Metasploit::Cache::Module::Instance::Load} from the `#initialize` Hash.
  #
  # # Payloads
  #
  # ## Ruby Module
  #
  # For payloads Metasploit Modules, the {Metasploit::Cache::Module::Ancestor#real_pathname} contains a ruby Module,
  # which is mixed into a base class, `Msf::Payload`, to form a subclass, so the ruby Module's
  # {#ephemeral_cache_by_source} will only contain the one source:
  # * `:ancestor` - metadata gathered from the {Metasploit::Cache::Module::Ancestor::Load}
  #
  # ## Ruby Class for single payloads
  #
  # The subclass of the payload base class, `Msf::Payload`, with the
  # {Metasploit::Cache::Payload::Single::Ancestor#real_pathname} `Module` mixed in, will contain the ephemeral cache
  # from two sources:
  # * `:class` - metadata gathered from the {Metasploit::Cache::Module::Class::Load} from `Class` constants or methods.
  # * `:instance` - metadata gathered from the {Metasploit::Cache::Module::Instance::Load} from the `#initialize` Hash.
  #
  # ## Ruby Class for stage payloads
  #
  # The subclass of the payload base class, `Msf::Payload`, with the
  # {Metasploit::Cache::Payload::Stage::Ancestor#real_pathname} `Module` mixed in, will contain the ephemeral cache from
  # two sources:
  # * `:class` - metadata gathered from the {Metasploit::Cache::Module::Class::Load} from `Class` constants or methods.
  # * `:instance` - metadata gathered from the {Metasploit::Cache::Module::Instance::Load} from the `#initialize` Hash.
  #
  # ## Ruby Class for stager payloads
  #
  # The subclass of the payload base class, `Msf::Payload`, with the
  # {Metasploit::Cache::Payload::Stager::Ancestor#real_pathname} `Module` mixed in, will contain the ephemeral cache
  # from two sources:
  # * `:class` - metadata gathered from the {Metasploit::Cache::Module::Class::Load} from `Class` constants or methods.
  # * `:instance` - metadata gathered from the {Metasploit::Cache::Module::Instance::Load} from the `#initialize` Hash.
  #
  # ## Ruby Class for staged payloads
  #
  # The subclass of the payload base class, `Msf::Payload`, with the
  # {Metasploit::Cache::Payload::Stage::Ancestor#real_pathname} `Module`,
  # {Metasploit::Cache::Payload::Stager::Ancestor#real_pathname} `Module`, and the stager's handler `Module` mixed in
  # will contain the ephemeral cache from two sources:
  # * `:class` - metadata gathered from the {Metasploit::Cache::Module::Class::Load} from `Class` constants or methods.
  # * `:instance` - metadata gathered from the {Metasploit::Cache::Module::Instance::Load} from the `#initialize` Hash.
  def ephemeral_cache_by_source
    @ephemeral_cache_by_source ||= {}
  end
end