FactoryGirl.define do
  factory :metasploit_cache_module_ancestor,
          class: Metasploit::Cache::Module::Ancestor do
    transient do
      module_type { generate :metasploit_cache_non_payload_module_type }
      reference_name { generate :metasploit_cache_module_ancestor_reference_name }

      #
      # Callback helpers
      #

      before_write_template {
        ->(module_ancestor, evaluator){}
      }
      write_template {
        ->(module_ancestor, evaluator){
          Metasploit::Cache::Module::Ancestor::Spec::Template.write(module_ancestor: module_ancestor)
        }
      }
    end

    #
    # Callbacks
    #

    after(:build) do |module_ancestor, evaluator|
      instance_exec(module_ancestor, evaluator, &evaluator.before_write_template)
      instance_exec(module_ancestor, evaluator, &evaluator.write_template)
    end

    #
    # Associations
    #

    association :parent_path, :factory => :metasploit_cache_module_path

    #
    # Attributes
    #

    # depends on module_type and reference_name
    relative_path {
      if module_type
        module_type_directory = Metasploit::Cache::Module::Ancestor::DIRECTORY_BY_MODULE_TYPE.fetch(module_type, module_type)

        "#{module_type_directory}/#{reference_name}#{Metasploit::Cache::Module::Ancestor::EXTENSION}"
      end
    }
  end

  minimum_version = 1
  maximum_version = 4
  range = maximum_version - minimum_version + 1

  sequence :metasploit_cache_module_ancestor_metasploit_module_relative_name do |n|
    version = (n % range) + minimum_version

    "Metasploit#{version}"
  end

  sequence :metasploit_cache_module_ancestor_reference_name do |n|
    [
        'metasploit',
        'cache',
        'module',
        'ancestor',
        'reference',
        "name#{n}"
    ].join('/')
  end
end