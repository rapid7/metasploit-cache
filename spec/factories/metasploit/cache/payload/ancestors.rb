FactoryGirl.define do
  sequence :metasploit_cache_payload_ancestor_factory,
           Metasploit::Cache::Payload::Ancestor::Spec.random_factory

  sequence :metasploit_cache_payload_ancestor_payload_name do |n|
    [
        'metasploit',
        'cache',
        'payload',
        'ancestor',
        'payload',
        "name#{n}"
    ].join('/')
  end

  trait :metasploit_cache_payload_ancestor do
    # first to allow overrides
    metasploit_cache_module_ancestor

    transient do
      module_type { 'payload' }
      payload_name { generate :metasploit_cache_payload_ancestor_payload_name }

      # depends on payload_name and payload_type
      reference_name {
        "#{payload_type.pluralize}/#{payload_name}"
      }
    end
  end

  trait :metasploit_cache_payload_ancestor_content do
    transient do
      content? { true }
      metasploit_module_relative_name { generate :metasploit_cache_module_ancestor_metasploit_module_relative_name }
    end

    #
    # Callbacks
    #

    after(:build) do |payload_ancestor, evaluator|
      # needed to allow for usage of trait with invalid relative_path, when `content?: false` should be set
      if evaluator.content?
        context = Object.new
        cell = Cell::Base.cell_for(
                             'metasploit/cache/payload/ancestor',
                             context,
                             payload_ancestor,
                             metasploit_module_relative_name: evaluator.metasploit_module_relative_name
        )

        real_pathname = payload_ancestor.real_pathname

        unless real_pathname
          raise ArgumentError,
                "#{payload_ancestor.class}#real_pathname is `nil` and content cannot be written.  " \
                "If this is expected, set `content?: false` " \
                "when using the :metasploit_cache_payload_ancestor_content trait."
        end

        # make directory
        real_pathname.parent.mkpath

        real_pathname.open('wb') do |f|
          f.write(cell.call)
        end
      end
    end
  end
end