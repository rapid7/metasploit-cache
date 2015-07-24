FactoryGirl.define do
  #
  # Factories
  #

  factory :metasploit_cache_auxiliary_instance,
          class: Metasploit::Cache::Auxiliary::Instance,
          traits: [
              :metasploit_cache_actionable_actions,
              :metasploit_cache_contributable_contributions,
              :metasploit_cache_licensable_licensable_licenses,
              # Must be after all association traits so associations are built when writing contents
              :metasploit_cache_auxiliary_instance_auxiliary_class_ancestor_contents
          ] do
    description { generate :metasploit_cache_auxiliary_instance_description }
    name { generate :metasploit_cache_auxiliary_instance_name }
    stance { generate :metasploit_cache_module_stance }

    #
    # Associations
    #

    association :auxiliary_class, factory: :metasploit_cache_auxiliary_class
  end

  #
  # Sequences
  #

  sequence :metasploit_cache_auxiliary_instance_description do |n|
    "Metasploit::Cache::Auxiliary::Instance#description #{n}"
  end

  sequence :metasploit_cache_auxiliary_instance_name do |n|
    "Metasploit::Cache::Auxiliary::Instance#name #{n}"
  end

  #
  # Traits
  #

  trait :metasploit_cache_auxiliary_instance_auxiliary_class_ancestor_contents do
    transient do
      auxiliary_class_ancestor_contents? true
      auxiliary_class_ancestor_metasploit_class_relative_name { generate :metasploit_cache_module_ancestor_metasploit_module_relative_name }
      auxiliary_class_ancestor_superclass { 'Metasploit::Cache::Direct::Class::Superclass' }
    end

    after(:build) do |auxiliary_instance, evaluator|
      if evaluator.auxiliary_class_ancestor_contents?
        auxiliary_class = auxiliary_instance.auxiliary_class

        if auxiliary_class.nil?
          raise ArgumentError,
                "#{auxiliary_instance.class}#auxiliary_class is `nil` and it can't be used to look up " \
                "Metasploit::Cache::Direct::Class#ancestor to write content. " \
                "If this is expected, set `auxiliary_class_ancestor_contents?: false` " \
                "when using the :metasploit_cache_auxiliary_instance_auxiliary_class_ancestor_contents trait."
        end

        auxiliary_ancestor = auxiliary_class.ancestor

        if auxiliary_ancestor.nil?
          raise ArgumentError,
                "#{auxiliary_class.class}#ancestor is `nil` and content cannot be written.  " \
                "If this is expected, set `auxiliary_ancestor_contents?: false` " \
                "when using the :metasploit_cache_auxiliary_instance_auxiliary_class_ancestor_contents trait."
        end

        real_pathname = auxiliary_ancestor.real_pathname

        unless real_pathname
          raise ArgumentError,
                "#{auxiliary_ancestor.class}#real_pathname is `nil` and content cannot be written.  " \
                "If this is expected, set `auxiliary_class_ancestor_contents?: false` " \
                "when using the :metasploit_cache_auxiliary_instance_auxiliary_class_ancestor_contents trait."
        end

        # make directory
        real_pathname.parent.mkpath

        context = Object.new
        cell = Cell::Base.cell_for(
            'metasploit/cache/auxiliary/instance/auxiliary_class/ancestor',
            context,
            auxiliary_instance,
            metasploit_class_relative_name: evaluator.auxiliary_class_ancestor_metasploit_class_relative_name,
            superclass: evaluator.auxiliary_class_ancestor_superclass
        )

        real_pathname.open('wb') do |f|
          f.write(cell.call)
        end
      end
    end
  end
end