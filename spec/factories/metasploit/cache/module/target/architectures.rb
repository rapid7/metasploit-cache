FactoryGirl.define do
  factory :metasploit_cache_module_target_architecture,
          class: Metasploit::Cache::Module::Target::Architecture do
    architecture { generate :metasploit_cache_architecture }
    association :module_target,
                factory: :metasploit_cache_module_target,
                strategy: :build,
                # disable module_target factory from building target_architectures since this factory is already
                # building one
                target_architectures_length: 0

    after(:build) do |module_target_architecture|
      module_target = module_target_architecture.module_target

      if module_target
        unless module_target.target_architectures.include? module_target_architecture
          module_target.target_architectures << module_target_architecture
        end
      end
    end
  end
end