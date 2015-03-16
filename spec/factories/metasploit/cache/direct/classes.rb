FactoryGirl.define do
  #
  # Sequences
  #

  sequence :metasploit_cache_direct_class_factory,
           Metasploit::Cache::Direct::Class::Spec.random_factory

  #
  # Traits
  #

  trait :metasploit_cache_direct_class do
    #
    # Associations
    #

    rank { generate :metasploit_cache_module_rank }
  end

  trait :metasploit_cache_direct_class_ancestor_content do
    transient do
      ancestor_content? { true }
      ancestor_metasploit_class_relative_name { generate :metasploit_cache_module_ancestor_metasploit_module_relative_name }
      ancestor_superclass { 'Metasploit::Cache::Ranked' }
    end

    #
    # Callbacks
    #

    after(:build) do |direct_class, evaluator|
      # needed to allow for usage of trait with invalid Metasploit::Cache::Module::Ancestor#relative_path when
      # `ancestor_content?: false` should be set
      if evaluator.ancestor_content?
        module_ancestor = direct_class.ancestor

        if module_ancestor.nil?
          raise ArgumentError,
                "#{direct_class.class}#ancestor is `nil` and content cannot be written.  " \
                "If this is expected, set `ancestor_content?: false` " \
                "when using the :metasploit_cache_direct_class_ancestor_content trait."
        end

        real_pathname = module_ancestor.real_pathname

        unless real_pathname
          raise ArgumentError,
                "#{module_ancestor.class}#real_pathname is `nil` and content cannot be written.  " \
                "If this is expected, set `ancestor_content?: false` " \
                "when using the :metasploit_cache_direct_class_ancestor_ancestor_content trait."
        end

        # make directory
        real_pathname.parent.mkpath

        context = Object.new
        cell = Cell::Base.cell_for(
            'metasploit/cache/direct/class/ancestor',
            context,
            direct_class,
            metasploit_module_relative_name: evaluator.ancestor_metasploit_class_relative_name,
            superclass: evaluator.ancestor_superclass
        )

        real_pathname.open('wb') do |f|
          f.write(cell.call)
        end
      end
    end
  end
end