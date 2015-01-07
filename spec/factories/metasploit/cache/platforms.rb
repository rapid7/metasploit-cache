FactoryGirl.define do
  fully_qualified_names = Metasploit::Cache::Platform.fully_qualified_name_set.sort
  platform_count = fully_qualified_names.length

  sequence :metasploit_cache_platform do |n|
    fully_qualified_name = fully_qualified_names[n % platform_count]

    platform = Metasploit::Cache::Platform.where(fully_qualified_name: fully_qualified_name).first

    unless platform
      raise ArgumentError,
            "Metasploit::Cache::Platform with fully_qualified_name (#{fully_qualified_name}) has not been seeded."
    end

    platform
  end
end