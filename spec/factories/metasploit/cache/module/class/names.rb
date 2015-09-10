FactoryGirl.define do
  factory :metasploit_cache_module_class_name,
          class: Metasploit::Cache::Module::Class::Name do
    reference {
      module_class.reference_name
    }

    after(:build) do |module_class_name, _evaluator|
      module_class_name.module_class.name = module_class_name
    end

    factory :metasploit_cache_auxiliary_class_name do
      association :module_class,
                  factory: :metasploit_cache_auxiliary_class,
                  strategy: :build

      module_type 'auxiliary'
    end

    factory :metasploit_cache_encoder_class_name do
      association :module_class,
                  factory: :metasploit_cache_encoder_class,
                  strategy: :build

      module_type 'encoder'
    end

    factory :metasploit_cache_exploit_class_name do
      association :module_class,
                  factory: :metasploit_cache_exploit_class,
                  strategy: :build

      module_type 'exploit'
    end

    factory :metasploit_cache_nop_class_name do
      association :module_class,
                  factory: :metasploit_cache_nop_class,
                  strategy: :build

      module_type 'nop'
    end

    factory :metasploit_cache_post_class_name do
      association :module_class,
                  factory: :metasploit_cache_post_class,
                  strategy: :build

      module_type 'post'
    end
  end
end