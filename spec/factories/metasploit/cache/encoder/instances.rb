FactoryGirl.define do
  #
  # Factories
  #

  factory :metasploit_cache_encoder_instance,
          class: Metasploit::Cache::Encoder::Instance,
          traits: [
              :metasploit_cache_architecturable_architecturable_architectures,
              :metasploit_cache_contributable_contributions,
              :metasploit_cache_licensable_licensable_licenses,
              :metasploit_cache_platformable_platformable_platforms,
              # Must be after all association traits so associations are populated before generating content
              :metasploit_cache_encoder_instance_encoder_class_ancestor_contents
          ] do
    description { generate :metasploit_cache_encoder_instance_description }
    name { generate :metasploit_cache_encoder_instance_name }

    #
    # Associations
    #

    association :encoder_class, factory: :metasploit_cache_encoder_class
  end

  #
  # Sequences
  #

  sequence :metasploit_cache_encoder_instance_description do |n|
    "Metasploit::Cache::Encoder::Instance#description #{n}"
  end

  sequence :metasploit_cache_encoder_instance_name do |n|
    "Metasploit::Cache::Encoder::Instance#name #{n}"
  end

  #
  # Traits
  #

  trait :metasploit_cache_encoder_instance_encoder_class_ancestor_contents do
    transient do
      encoder_class_ancestor_contents? true
      encoder_class_ancestor_metasploit_class_relative_name { generate :metasploit_cache_module_ancestor_metasploit_module_relative_name }
      encoder_class_ancestor_superclass { 'Metasploit::Cache::Direct::Class::Superclass' }
    end

    after(:build) do |encoder_instance, evaluator|
      if evaluator.encoder_class_ancestor_contents?
        encoder_class = encoder_instance.encoder_class

        if encoder_class.nil?
          raise ArgumentError,
                "#{encoder_instance.class}#encoder_class is `nil` and it can't be used to look up " \
                "Metasploit::Cache::Direct::Class#ancestor to write content. " \
                "If this is expected, set `encoder_class_ancestor_contents?: false` " \
                "when using the :metasploit_cache_encoder_instance_encoder_class_ancestor_contents trait."
        end

        encoder_ancestor = encoder_class.ancestor

        if encoder_ancestor.nil?
          raise ArgumentError,
                "#{encoder_class.class}#ancestor is `nil` and content cannot be written.  " \
                "If this is expected, set `encoder_ancestor_contents?: false` " \
                "when using the :metasploit_cache_encoder_instance_encoder_class_ancestor_contents trait."
        end

        real_pathname = encoder_ancestor.real_pathname

        unless real_pathname
          raise ArgumentError,
                "#{encoder_ancestor.class}#real_pathname is `nil` and content cannot be written.  " \
                "If this is expected, set `encoder_class_ancestor_contents?: false` " \
                "when using the :metasploit_cache_encoder_instance_encoder_class_ancestor_contents trait."
        end

        cell = Metasploit::Cache::Encoder::Instance::EncoderClass::AncestorCell.(encoder_instance)

        # make directory
        real_pathname.parent.mkpath

        real_pathname.open('wb') do |f|
          f.write(
              cell.(
                  :show,
                  metasploit_class_relative_name: evaluator.encoder_class_ancestor_metasploit_class_relative_name,
                  superclass: evaluator.encoder_class_ancestor_superclass
              )
          )
        end
      end
    end
  end
end