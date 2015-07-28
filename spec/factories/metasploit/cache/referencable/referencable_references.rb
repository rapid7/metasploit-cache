FactoryGirl.define do
  trait :metasploit_cache_referencable_referencable_references do
    transient do
      referencable_reference_count 1
    end

    after(:build) do |referencable, evaluator|
      referencable.referencable_references = build_list(
        :metasploit_cache_exploit_reference,
        evaluator.referencable_reference_count,
        referencable: referencable
      )
    end
  end
end