FactoryGirl.define do
  factory :metasploit_cache_module_platform,
          class: Metasploit::Cache::Module::Platform do
    transient do
      # have to use transient module_type from metasploit_cache_modules_platform_module_type sequence to ensure
      # module_instance will support module platforms.
      module_class { FactoryGirl.create(:metasploit_cache_module_class, module_type: module_type) }
      module_type { generate :metasploit_cache_module_platform_module_type }
    end

    #
    # Associations
    #

    module_instance {
      FactoryGirl.build(
          :metasploit_cache_module_instance,
          module_class: module_class,
          # disable module_instance factory from building module_platforms since this factory is already building one
          module_platforms_length: 0
      )
    }
    platform { generate :metasploit_cache_platform }

    #
    # Callbacks
    #

    after(:build) do |module_platform|
      module_instance = module_platform.module_instance

      if module_instance
        unless module_instance.module_platforms.include? module_platform
          module_instance.module_platforms << module_platform
        end
      end
    end
  end

  module_platforms_module_types = Metasploit::Cache::Module::Instance.module_types_that_allow(:module_platforms)
  targets_module_types = Metasploit::Cache::Module::Instance.module_types_that_allow(:targets)

  # have to remove target supporting types so that target platforms won't interfere with module platforms
  metasploit_cache_module_platform_module_types = module_platforms_module_types - targets_module_types

  sequence :metasploit_cache_module_platform_module_type, metasploit_cache_module_platform_module_types.cycle
end