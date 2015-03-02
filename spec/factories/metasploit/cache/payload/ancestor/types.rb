FactoryGirl.define do
  infinite_random_type = Enumerator.new do |yielder|
    loop do
      yielder.yield Metasploit::Cache::Payload::Ancestor::Type::ALL.sample
    end
  end

  sequence :metasploit_cache_payload_ancestor_type, infinite_random_type
end