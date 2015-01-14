FactoryGirl.define do
  factory :metasploit_cache_spec_template,
          class: Metasploit::Cache::Spec::Template,
          traits: [
              :metasploit_model_base
          ] do
    destination_pathname { generate :metasploit_cache_spec_template_destination_pathname }
    overwrite false
    search_pathnames {
      [
          # Relative path to root
          Pathname.new('spec/templates')
      ]
    }
    source_relative_name { 'base' }
  end

  sequence :metasploit_cache_spec_template_destination_pathname do |n|
    Metasploit::Model::Spec.temporary_pathname.join(
        'metasploit',
        'cache',
        'spec',
        'template',
        "destination#{n}.rb"
    )
  end
end