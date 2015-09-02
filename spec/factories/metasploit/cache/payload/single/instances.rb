FactoryGirl.define do
  factory :metasploit_cache_payload_single_instance,
          class: Metasploit::Cache::Payload::Single::Instance do
    description { generate :metasploit_cache_payload_single_instance_description }
    name { generate :metasploit_cache_payload_single_instance_name }
    privileged { generate :metasploit_cache_payload_single_instance_privileged }

    #
    # Associations
    #

    association :payload_single_unhandled_class, factory: :metasploit_cache_payload_single_unhandled_class

    factory :full_metasploit_cache_payload_single_instance,
            traits: [
                :metasploit_cache_architecturable_architecturable_architectures,
                :metasploit_cache_contributable_contributions,
                :metasploit_cache_licensable_licensable_licenses,
                :metasploit_cache_payload_handable_handler,
                :metasploit_cache_platformable_platformable_platforms,
                # Must be after all association building traits so assocations are populated for writing contents
                :metasploit_cache_payload_single_instance_payload_single_unhandled_class_ancestor_contents
            ]
  end

  #
  # Sequences
  #

  sequence(:metasploit_cache_payload_single_instance_description) { |n|
    "Metasploit::Cache::Payload::Single::Instance#description #{n}"
  }

  sequence(:metasploit_cache_payload_single_instance_name) { |n|
    "Metasploit::Cache::Payload::Single::Instance#name #{n}"
  }

  sequence :metasploit_cache_payload_single_instance_privileged, Metasploit::Cache::Spec.sample_stream([false, true])

  #
  # Traits
  #

  trait :metasploit_cache_payload_single_instance_payload_single_unhandled_class_ancestor_contents do
    transient do
      payload_single_unhandled_class_ancestor_metasploit_module_relative_name { generate :metasploit_cache_module_ancestor_metasploit_module_relative_name }
    end

    after(:build) do |payload_single_instance, evaluator|
      payload_single_unhandled_class = payload_single_instance.payload_single_unhandled_class

      if payload_single_unhandled_class.nil?
        raise ArgumentError,
              "#{payload_single_instance.class}#payload_single_unhandled_class is `nil` and it can't be used to look up " \
                "Metasploit::Cache::Direct::Class#ancestor to write content."
      end

      payload_single_ancestor = payload_single_unhandled_class.ancestor

      if payload_single_ancestor.nil?
        raise ArgumentError, "#{payload_single_unhandled_class.class}#ancestor is `nil` and content cannot be written."
      end

      real_pathname = payload_single_ancestor.real_pathname

      unless real_pathname
        raise ArgumentError, "#{payload_single_ancestor.class}#real_pathname is `nil` and content cannot be written."
      end

      cell = Metasploit::Cache::Payload::Single::Instance::PayloadSingleUnhandledClass::AncestorCell.(
          payload_single_instance
      )

      # make directory
      real_pathname.parent.mkpath

      real_pathname.open('wb') do |f|
        f.write(
            cell.(
                :show,
                metasploit_module_relative_name: evaluator.payload_single_unhandled_class_ancestor_metasploit_module_relative_name
            )
        )
      end
    end
  end
end