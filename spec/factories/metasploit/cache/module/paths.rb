FactoryGirl.define do
  sequence :metasploit_cache_module_path_gem do |n|
    "metasploit_cache_module_path_gem#{n}"
  end

  sequence :metasploit_cache_module_path_name do |n|
    "metasploit_cache_module_path_name#{n}"
  end

  sequence :metasploit_cache_module_path_real_path do |n|
    pathname = Metasploit::Model::Spec.temporary_pathname.join(
        'metasploit',
        'cache',
        'module',
        'path',
        'real',
        'path',
        n.to_s
    )
    Metasploit::Model::Spec::PathnameCollision.check!(pathname)
    pathname.mkpath

    pathname.to_path
  end

  sequence :metasploit_cache_module_path_directory_real_path do |n|
    pathname = Metasploit::Model::Spec.temporary_pathname.join(
        'metasploit',
        'cache',
        'module',
        'path',
        'directory',
        'real',
        'path',
        n.to_s
    )
    Metasploit::Model::Spec::PathnameCollision.check!(pathname)
    pathname.mkpath

    pathname.to_path
  end

  trait :unnamed_metasploit_cache_module_path do
    real_path { generate :metasploit_cache_module_path_real_path }
  end

  trait :named_metasploit_cache_module_path do
    gem { generate :metasploit_cache_module_path_gem }
    name { generate :metasploit_cache_module_path_name }
  end
end