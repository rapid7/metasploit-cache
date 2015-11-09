FactoryGirl.define do
  #
  # Traits
  #

  trait :metasploit_cache_payload_unhandled_class do
    metasploit_cache_direct_class
  end

  trait :metasploit_cache_payload_unhandled_class_ancestor_contents do
    transient do
      ancestor_contents? { true }
      ancestor_metasploit_class_relative_name { generate :metasploit_cache_module_ancestor_metasploit_module_relative_name }
    end

    #
    # Callbacks
    #

    after(:build) do |direct_class, evaluator|
      # needed to allow for usage of trait with invalid Metasploit::Cache::Module::Ancestor#relative_path when
      # `ancestor_contents?: false` should be set
      if evaluator.ancestor_contents?
        module_ancestor = direct_class.ancestor

        if module_ancestor.nil?
          raise ArgumentError,
                "#{direct_class.class}#ancestor is `nil` and content cannot be written.  " \
                "If this is expected, set `ancestor_contents?: false` " \
                "when using the :metasploit_cache_payload_unhandled_class_ancestor_contents trait."
        end

        real_pathname = module_ancestor.real_pathname

        unless real_pathname
          raise ArgumentError,
                "#{module_ancestor.class}#real_pathname is `nil` and content cannot be written.  " \
                "If this is expected, set `ancestor_contents?: false` " \
                "when using the :metasploit_cache_payload_unhandled_class_ancestor_contents trait."
        end

        cell = Metasploit::Cache::Payload::Unhandled::Class::AncestorCell.(direct_class)

        # make directory
        real_pathname.parent.mkpath

        real_pathname.open('wb') do |f|
          f.write(
              cell.(
                  :show,
                  metasploit_module_relative_name: evaluator.ancestor_metasploit_class_relative_name,
              )
          )
        end
      end
    end
  end
end