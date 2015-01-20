RSpec::Matchers.define :allow_attribute do |attribute|
  description do
    "allow zero or more items for #{attribute}"
  end

  failure_message do |module_instance|
    "expected that #{module_instance.class} with #{module_instance.module_type} #module_type would allow zero or more items for #{attribute}"
  end

  failure_message_when_negated do |module_instance|
    "expected that #{module_instance.class} with #{module_instance.module_type} #module_type would not allow any items for #{attribute}"
  end

  match do |module_instance|
    module_instance.allows?(attribute)
  end
end