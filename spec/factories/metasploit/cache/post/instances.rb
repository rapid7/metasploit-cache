FactoryGirl.define do
  factory :metasploit_cache_post_instance,
          class: Metasploit::Cache::Post::Instance do
    description { generate :metasploit_cache_post_instance_description }
    disclosed_on { generate :metasploit_cache_post_instance_disclosed_on }
    name { generate :metasploit_cache_post_instance_name }
    privileged { generate :metasploit_cache_post_instance_privileged }

    #
    # Associations
    #

    association :post_class, factory: :metasploit_cache_post_class

    factory :full_metasploit_cache_post_instance,
        traits: [
            :metasploit_cache_actionable_actions,
            :metasploit_cache_architecturable_architecturable_architectures,
            :metasploit_cache_contributable_contributions,
            :metasploit_cache_licensable_licensable_licenses,
            :metasploit_cache_platformable_platformable_platforms,
            :metasploit_cache_referencable_referencable_references,
            # Must be after all association building traits so assocations are populated for writing contents
            :metasploit_cache_post_instance_post_class_ancestor_contents
        ]
  end

  #
  # Sequences
  #

  sequence :metasploit_cache_post_instance_description do |n|
    "Metasploit::Cache::Post::Instance#description #{n}"
  end

  sequence :metasploit_cache_post_instance_disclosed_on do |n|
    n.days.ago
  end

  sequence :metasploit_cache_post_instance_name do |n|
    "Metasploit::Cache::Post::Instance"
  end

  sequence :metasploit_cache_post_instance_privileged, Metasploit::Cache::Spec.sample_stream([false, true])
  
  #
  # Traits
  #
  
  trait :metasploit_cache_post_instance_post_class_ancestor_contents do
    transient do
      post_class_ancestor_contents? true
      post_class_ancestor_metasploit_class_relative_name { generate :metasploit_cache_module_ancestor_metasploit_module_relative_name }
      post_class_ancestor_superclass { 'Metasploit::Cache::Direct::Class::Superclass' }
    end

    after(:build) do |post_instance, evaluator|
      if evaluator.post_class_ancestor_contents?
        post_class = post_instance.post_class

        if post_class.nil?
          raise ArgumentError,
                "#{post_instance.class}#post_class is `nil` and it can't be used to look up " \
                "Metasploit::Cache::Direct::Class#ancestor to write content. " \
                "If this is expected, set `post_class_ancestor_contents?: false` " \
                "when using the :metasploit_cache_post_instance_post_class_ancestor_contents trait."
        end

        post_ancestor = post_class.ancestor

        if post_ancestor.nil?
          raise ArgumentError,
                "#{post_class.class}#ancestor is `nil` and content cannot be written.  " \
                "If this is expected, set `post_ancestor_contents?: false` " \
                "when using the :metasploit_cache_post_instance_post_class_ancestor_contents trait."
        end

        real_pathname = post_ancestor.real_pathname

        unless real_pathname
          raise ArgumentError,
                "#{post_ancestor.class}#real_pathname is `nil` and content cannot be written.  " \
                "If this is expected, set `post_class_ancestor_contents?: false` " \
                "when using the :metasploit_cache_post_instance_post_class_ancestor_contents trait."
        end

        cell = Metasploit::Cache::Post::Instance::PostClass::AncestorCell.(post_instance)

        # make directory
        real_pathname.parent.mkpath

        real_pathname.open('wb') do |f|
          f.write(
              cell.(
                  :show,
                  metasploit_class_relative_name: evaluator.post_class_ancestor_metasploit_class_relative_name,
                  superclass: evaluator.post_class_ancestor_superclass
              )
          )
        end
      end
    end
  end
end