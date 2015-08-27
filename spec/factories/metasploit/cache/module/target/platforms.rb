FactoryGirl.define do
  factory :metasploit_cache_module_target_platform,
          class: Metasploit::Cache::Module::Target::Platform do
    association :module_target,
                factory: :metasploit_cache_module_target,
                strategy: :build,
                # disable module_target factory from building target_platforms since this factory is already
                # building one
                target_platforms_length: 0

    platform { generate :metasploit_cache_platform }

    after(:build) do |module_target_platform|
      module_target = module_target_platform.module_target

      if module_target
        unless module_target.target_platforms.include? module_target_platform
          module_target.target_platforms << module_target_platform
        end
      end
    end
  end
end