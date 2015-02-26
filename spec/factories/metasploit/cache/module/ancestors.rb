FactoryGirl.define do
  factory :metasploit_cache_module_ancestor,
          class: Metasploit::Cache::Module::Ancestor do
    transient do
      module_type { generate :metasploit_cache_module_type }

      # depends on module_type
      payload_type {
        if payload?
          'single'
        end
      }

      # depends on module_type and payload_type
      reference_name {
        if payload?
          payload_type_directory = payload_type.pluralize
          relative_payload_name = generate :metasploit_cache_module_ancestor_relative_payload_name

          [
              payload_type_directory,
              relative_payload_name
          ].join('/')
        else
          generate :metasploit_cache_module_ancestor_non_payload_reference_name
        end
      }

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

    #
    # Child Factories
    #

    factory :non_payload_metasploit_cache_module_ancestor do
      transient do
        module_type { generate :metasploit_cache_non_payload_module_type }
        payload_type nil
      end
    end

    factory :payload_metasploit_cache_module_ancestor do
      transient do
        module_type 'payload'
        payload_type { 'single' }
      end

      #
      # Attributes
      #

      reference_name {
        payload_type_directory = payload_type.pluralize
        relative_payload_name = generate :metasploit_cache_module_ancestor_relative_payload_name

        [
            payload_type_directory,
            relative_payload_name
        ].join('/')
      }

      factory :single_payload_metasploit_cache_module_ancestor do
        transient do
          payload_type 'single'
        end
      end

      factory :stage_payload_metasploit_cache_module_ancestor do
        transient do
          payload_type 'stage'
        end
      end
    end
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

  sequence :metasploit_cache_module_ancestor_non_payload_reference_name do |n|
    [
        'metasploit',
        'cache',
        'module',
        'ancestor',
        'non',
        'payload',
        'reference',
        "name#{n}"
    ].join('/')
  end

  sequence :metasploit_cache_module_ancestor_payload_reference_name do |n|
    [
        'singles',
        'metasploit',
        'cache',
        'module',
        'ancestor',
        'payload',
        'reference',
        "name#{n}"
    ].join('/')
  end

  sequence :metasploit_cache_module_ancestor_relative_payload_name do |n|
    [
        'metasploit',
        'cache',
        'module',
        'ancestor',
        'relative',
        'payload',
        "name#{n}"
    ].join('/')
  end
end