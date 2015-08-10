FactoryGirl.define do
  factory :metasploit_cache_nop_instance,
          class: Metasploit::Cache::Nop::Instance do
    description { generate :metasploit_cache_nop_instance_description }
    name { generate :metasploit_cache_nop_instance_name }

    #
    # Associations
    #

    association :nop_class, factory: :metasploit_cache_nop_class

    factory :full_metasploit_cache_nop_instance,
            traits: [
                :metasploit_cache_architecturable_architecturable_architectures,
                :metasploit_cache_contributable_contributions,
                :metasploit_cache_licensable_licensable_licenses,
                :metasploit_cache_platformable_platformable_platforms,
                # Must be after all association building traits so assocations are populated for writing contents
                :metasploit_cache_nop_instance_nop_class_ancestor_contents
            ]
  end

  #
  # Sequences
  #

  sequence(:metasploit_cache_nop_instance_description) { |n|
    "Metasploit::Cache::Nop::Instance#description #{n}"
  }

  sequence(:metasploit_cache_nop_instance_name) { |n|
    "Metasploit::Cache::Nop::Instance#name #{n}"
  }
  
  #
  # Traits
  #
  
  trait :metasploit_cache_nop_instance_nop_class_ancestor_contents do
    transient do
      nop_class_ancestor_contents? true
      nop_class_ancestor_metasploit_class_relative_name { generate :metasploit_cache_module_ancestor_metasploit_module_relative_name }
      nop_class_ancestor_superclass { 'Metasploit::Cache::Direct::Class::Superclass' }
    end

    after(:build) do |nop_instance, evaluator|
      if evaluator.nop_class_ancestor_contents?
        nop_class = nop_instance.nop_class

        if nop_class.nil?
          raise ArgumentError,
                "#{nop_instance.class}#nop_class is `nil` and it can't be used to look up " \
                "Metasploit::Cache::Direct::Class#ancestor to write content. " \
                "If this is expected, set `nop_class_ancestor_contents?: false` " \
                "when using the :metasploit_cache_nop_instance_nop_class_ancestor_contents trait."
        end

        nop_ancestor = nop_class.ancestor

        if nop_ancestor.nil?
          raise ArgumentError,
                "#{nop_class.class}#ancestor is `nil` and content cannot be written.  " \
                "If this is expected, set `nop_ancestor_contents?: false` " \
                "when using the :metasploit_cache_nop_instance_nop_class_ancestor_contents trait."
        end

        real_pathname = nop_ancestor.real_pathname

        unless real_pathname
          raise ArgumentError,
                "#{nop_ancestor.class}#real_pathname is `nil` and content cannot be written.  " \
                "If this is expected, set `nop_class_ancestor_contents?: false` " \
                "when using the :metasploit_cache_nop_instance_nop_class_ancestor_contents trait."
        end

        cell = Metasploit::Cache::Nop::Instance::NopClass::AncestorCell.(nop_instance)

        # make directory
        real_pathname.parent.mkpath

        real_pathname.open('wb') do |f|
          f.write(
              cell.(
                  :show,
                  metasploit_class_relative_name: evaluator.nop_class_ancestor_metasploit_class_relative_name,
                  superclass: evaluator.nop_class_ancestor_superclass
              )
          )
        end
      end
    end
  end
end